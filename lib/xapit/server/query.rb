module Xapit
  module Server
    class Query
      def initialize(clauses)
        @clauses = clauses
        @xapian_query = nil
      end

      def results
        enquire = Xapian::Enquire.new(Xapit.database.xapian_database)
        enquire.query = xapian_query
        enquire.mset(0, 200).matches.map do |match|
          class_name, id = match.document.data.split('-')
          {:class => class_name, :id => id, :relevance => match.percent}
        end
      end

      private

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
        end
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
