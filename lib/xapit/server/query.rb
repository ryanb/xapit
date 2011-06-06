module Xapit
  module Server
    class Query
      def initialize(clauses)
        @clauses = clauses
        @xapian_query = nil
      end

      def records
        enquire = Xapian::Enquire.new(Xapit.database.xapian_database)
        enquire.query = xapian_query
        enquire.set_sort_by_key_then_relevance(sorter, false) if sorter
        enquire.mset(0, 200).matches.map do |match|
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
          facets[attribute] = spy.values.map { |value| {:value => value.term, :count => value.termfreq} }
        end
        facets
      end

      def data
        {:records => records, :facets => facets}
      end

      private

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
          merge(:and, where_terms(value))
        when :or_where
          merge(:or, where_terms(value))
        when :not_where
          merge(:not, where_terms(value))
        when :similar_to
          similar_to(value)
        end
      end

      def similar_to(data)
        indexer = Indexer.new(data)
        terms = (indexer.text_terms + indexer.field_terms).map { |a| a.first }
        merge(:and, Xapian::Query.new(xapian_operator(:or), terms))
        merge(:not, ["Q#{data[:class]}-#{data[:id]}"])
      end

      def where_terms(conditions)
        conditions.map do |name, value|
          "X#{name}-#{value.to_s.downcase}"
        end
      end

      def search_query(text)
        # xapian_parser.parse_query(text, Xapian::QueryParser::FLAG_WILDCARD | Xapian::QueryParser::FLAG_BOOLEAN | Xapian::QueryParser::FLAG_LOVEHATE)
        xapian_parser.parse_query(text, Xapian::QueryParser::FLAG_BOOLEAN)
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
        else raise "Unknown Xapian operator #{operator}"
        end
      end

      def xapian_parser
        @xapian_parser ||= build_xapian_parser
      end

      def build_xapian_parser
        parser = Xapian::QueryParser.new
        parser.database = Xapit.database.xapian_database
        # parser.stemmer = Xapian::Stem.new(Config.stemming)
        # parser.stemming_strategy = Xapian::QueryParser::STEM_SOME
        parser.default_op = xapian_operator(:and)
        # if @member_class
        #   @member_class.xapit_index_blueprint.field_attributes.each do |field|
        #     parser.add_prefix(field.to_s, "X#{field}-")
        #   end
        # end
        parser
      end
    end
  end
end
