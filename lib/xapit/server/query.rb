module Xapit
  module Server
    class Query
      def initialize(clauses)
        @clauses = clauses
        @xapian_query = nil
      end

      def matches
        enquire = Xapian::Enquire.new(Xapit.database.xapian_database)
        enquire.query = xapian_query
        enquire.set_sort_by_key_then_relevance(sorter, false) if sorter
        enquire.mset((page.to_i-1)*per_page.to_i, per_page.to_i).matches
      end

      def records
        matches.map do |match|
          class_name, id = match.document.data.split('-')
          {:class => class_name, :id => id, :relevance => match.percent}
        end
      end

      def spelling_suggestion
        text = @clauses.map { |clause| clause[:search] }.compact.join(" ")
        if [text, *text.scan(/\w+/)].all? { |term| term_suggestion(term).nil? }
          nil
        else
          return term_suggestion(text) unless term_suggestion(text).to_s.empty?
          text.downcase.gsub(/\w+/) do |term|
            term_suggestion(term) || term
          end
        end
      end

      def facets
        facets = {}
        enquire = Xapian::Enquire.new(Xapit.database.xapian_database)
        enquire.query = xapian_query
        spies = facet_spies
        spies.values.each do |spy|
          enquire.add_matchspy(spy)
        end
        enquire.mset(0, 200)
        spies.each do |attribute, spy|
          values = {}
          spy.values.map do |spy_value|
            spy_value.term.split("\3").each do |term| # used to support multiple facet values
              values[term] ||= 0
              values[term] += spy_value.termfreq.to_i
            end
          end
          facets[attribute] = values.map { |value, count| {:value => value, :count => count} }
        end
        facets
      end

      def applied_facet_options
        facet_options = []
        @clauses.each do |clause|
          if clause[:match_facets]
            clause[:match_facets].each do |identifier|
              facet_options << facet_option(identifier)
            end
          end
        end
        facet_options
      end

      def facet_option(identifier)
        match = self.class.new([{:in_classes => ["FacetOption"]}, {:where => {:id => identifier}}]).matches.first
        if match.nil?
          raise "Unable to find facet option for #{identifier}."
        else
          name, value = match.document.data.split('|||')
          {:name => name, :value => value}
        end
      end

      def total
        enquire = Xapian::Enquire.new(Xapit.database.xapian_database)
        enquire.query = xapian_query
        enquire.mset(0, Xapit.database.xapian_database.doccount).matches_estimated
      end

      def data
        {:records => records, :facets => facets, :total => total}
      end

      private

      def page
        @clauses.map { |clause| clause[:page] }.compact.last || 1
      end

      def per_page
        @clauses.map { |clause| clause[:per_page] }.compact.last || 20
      end

      def term_suggestion(term)
        suggestion = Xapit.database.xapian_database.get_spelling_suggestion(term.downcase)
        suggestion.to_s.empty? ? nil : suggestion
      end

      def sorter
        if @clauses.any? { |c| c[:order] }
          sorter = Xapian::MultiValueKeyMaker.new
          @clauses.each do |clause|
            if clause[:order]
              attribute, direction = clause[:order]
              sorter.add_value(Xapit.value_index(:sortable, attribute), direction.to_sym == :desc)
            end
          end
          sorter
        end
      end

      def facet_spies
        spies = {}
        @clauses.each do |clause|
          if clause[:include_facets]
            clause[:include_facets].each do |facet|
              spies[facet] = Xapian::ValueCountMatchSpy.new(Xapit.value_index(:facet, facet))
            end
          end
        end
        spies
      end

      def xapian_query
        build_xapian_query if @query.nil?
        @xapian_query
      end

      def build_xapian_query
        @xapian_query = Xapian::Query.new("")
        @clauses.each do |clause|
          clause.each do |type, options|
            apply_clause(type, options)
          end
        end
      end

      def apply_clause(type, value)
        case type
        when :search
          merge(:and, search_query(value))
        when :where
          merge(:and, where_query(value))
        when :or_where
          merge(:or, where_query(value))
        when :not_where
          merge(:not, where_query(value))
        when :similar_to
          similar_to(value)
        when :match_facets
          merge(:and, facet_terms(value))
        end
      end

      def similar_to(data)
        indexer = Indexer.new(data)
        terms = (indexer.text_terms + indexer.field_terms).map { |a| a.first }
        merge(:and, Xapian::Query.new(xapian_operator(:or), terms))
        merge(:not, ["Q#{data[:class]}-#{data[:id]}"])
      end

      def where_query(conditions)
        queries = []
        terms = []
        conditions.each do |name, value|
          if value.kind_of?(Hash) && value[:from] && value[:to]
            queries << Xapian::Query.new(xapian_operator(:range), Xapit.value_index(:field, name), Xapit.serialize_value(value[:from]), Xapit.serialize_value(value[:to]))
          else
            terms << "X#{name}-#{value.to_s.downcase}"
          end
        end
        queries << Xapian::Query.new(xapian_operator(:and), terms) unless terms.empty?
        queries.inject(queries.shift) do |merged_query, query|
          Xapian::Query.new(xapian_operator(:and), merged_query, query)
        end
      end

      def where_terms(conditions)
        conditions.map do |name, value|
          "X#{name}-#{value.to_s.downcase}"
        end
      end

      def facet_terms(facets)
        facets.map { |facet| "F#{facet}" }
      end

      def search_query(text)
        xapian_parser.parse_query(text.gsub(/\b([a-z])\*/i, "\\1"), Xapian::QueryParser::FLAG_WILDCARD | Xapian::QueryParser::FLAG_BOOLEAN) # Xapian::QueryParser::FLAG_LOVEHATE
      end

      def merge(operator, query)
        query = Xapian::Query.new(xapian_operator(:and), query) unless query.kind_of? Xapian::Query
        @xapian_query = Xapian::Query.new(xapian_operator(operator), @xapian_query, query)
      end

      def xapian_operator(operator)
        case operator
        when :and then Xapian::Query::OP_AND
        when :or then Xapian::Query::OP_OR
        when :not then Xapian::Query::OP_AND_NOT
        when :range then Xapian::Query::OP_VALUE_RANGE
        else raise "Unknown Xapian operator #{operator}"
        end
      end

      def xapian_parser
        @xapian_parser ||= build_xapian_parser
      end

      def build_xapian_parser
        parser = Xapian::QueryParser.new
        parser.database = Xapit.database.xapian_database
        if Xapit.config[:stemming]
          parser.stemmer = Xapian::Stem.new(Xapit.config[:stemming])
          parser.stemming_strategy = Xapian::QueryParser::STEM_SOME
        end
        parser.default_op = xapian_operator(:and)
        @clauses.each do |clause|
          if clause[:search]
            clause[:search].scan(/([a-z0-9_]+)\:/i).each do
              parser.add_prefix($1, "X#{$1}-")
            end
          end
        end
        parser
      end
    end
  end
end
