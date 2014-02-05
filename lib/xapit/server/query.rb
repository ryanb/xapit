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
        enquire.cutoff!(min_relevance) if min_relevance
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
        enquire.mset(0, 10000)
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
          if clause[:with_facets]
            clause[:with_facets].each do |identifier|
              facet_options << facet_option(identifier)
            end
          end
        end
        facet_options.compact
      end

      def facet_option(identifier)
        match = self.class.new([{:in_classes => ["FacetOption"]}, {:where => {:id => identifier}}]).matches.first
        if match
          name, value = match.document.data.split('|||')
          {:id => identifier, :name => name, :value => value}
        end
      end

      def total
        enquire = Xapian::Enquire.new(Xapit.database.xapian_database)
        enquire.query = xapian_query
        enquire.cutoff!(min_relevance) if min_relevance
        enquire.mset(0, Xapit.database.xapian_database.doccount).matches_estimated
      end

      def data
        {:records => records, :facets => facets, :applied_facet_options => applied_facet_options, :total => total}
      end

      private

      def page
        @clauses.map { |clause| clause[:page] }.compact.last || 1
      end

      def per_page
        @clauses.map { |clause| clause[:per_page] }.compact.last || Xapit::Client::Collection::DEFAULT_PER_PAGE
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

      def min_relevance
        if clause = @clauses.select{|c| c[:min_relevance]}.first
          clause[:min_relevance].to_i
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
        when :or_search
          merge(:or, search_query(value))
        when :not_search
          merge(:not, search_query(value))
        when :where
          merge(:and, where_query(value))
        when :or_where
          merge(:or, where_query(value))
        when :not_where
          merge(:not, where_query(value))
        when :in_classes
          merge(:and, value.map { |c| "C#{c}" })
        when :not_in_classes
          merge(:not, value.map { |c| "C#{c}" })
        when :similar_to
          similar_to(value)
        when :with_facets
          merge(:and, facet_terms(value))
        when :all_terms
          merge(:and, value)
        when :any_terms
          merge(:and, Xapian::Query.new(xapian_operator(:or), value))
        when :not_terms
          merge(:not, Xapian::Query.new(xapian_operator(:or), value))
        end
      end

      def similar_to(data)
        indexer = Indexer.new(data)
        terms = (indexer.text_terms + indexer.field_terms).map { |a| a.first }
        merge(:and, Xapian::Query.new(xapian_operator(:or), terms))
        merge(:not, ["Q#{data[:class]}-#{data[:id]}"])
      end

      def where_query(conditions, operator = :and)
        queries = []
        terms = []
        conditions.each do |name, value|
          if value.kind_of?(Hash)
            if value[:from] && value[:to]
              queries << Xapian::Query.new(xapian_operator(:range), Xapit.value_index(:field, name), Xapit.serialize_value(value[:from]), Xapit.serialize_value(value[:to]))
            elsif value[:partial]
              parser = Xapian::QueryParser.new
              parser.database = Xapit.database.xapian_database
              queries << parser.parse_query(value[:partial].downcase[-1..-1], Xapian::QueryParser::FLAG_PARTIAL, "X#{name}-#{value[:partial].downcase[0..-2]}")
            else
              value.each do |k, v|
                queries << Xapian::Query.new(xapian_operator(k), Xapit.value_index(:field, name), Xapit.serialize_value(v))
              end
            end
          elsif value.kind_of?(Array)
            array_conditions = value.map { |v| [name, v] }
            queries << where_query(array_conditions, :or)
          else
            terms << "X#{name}-#{value.to_s.downcase}"
          end
        end
        queries << Xapian::Query.new(xapian_operator(operator), terms) unless terms.empty?
        queries.inject(queries.shift) do |merged_query, query|
          Xapian::Query.new(xapian_operator(operator), merged_query, query)
        end
      end

      def facet_terms(facets)
        facets.map { |facet| "F#{facet}" }
      end

      def search_query(text)
        clean_text = text.gsub(/\b([a-z])\*/i, "\\1").gsub(/[^\w\*\s:\/()]/u, "")
        xapian_parser.parse_query(clean_text, Xapian::QueryParser::FLAG_WILDCARD | Xapian::QueryParser::FLAG_BOOLEAN) # Xapian::QueryParser::FLAG_LOVEHATE
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
        when :gte then Xapian::Query::OP_VALUE_GE
        when :lte then Xapian::Query::OP_VALUE_LE
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
