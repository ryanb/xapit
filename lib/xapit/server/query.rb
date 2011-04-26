module Xapit
  module Server
    class Query
      def initialize(query)
        @query = query
      end

      def field_terms
        terms = []
        @query.each do |clause|
          if clause[:where]
            clause[:where].each do |name, value|
              terms << "X#{name}-#{value.to_s.downcase}"
            end
          end
        end
        terms
      end

      def search_terms
        terms = []
        @query.each do |clause|
          terms << clause[:search] if clause[:search]
        end
        terms
      end

      def results
        enquire = Xapian::Enquire.new(Xapit.database.xapian_database)
        enquire.query = Xapian::Query.new(Xapian::Query::OP_AND, search_terms)
        enquire.mset(0, 200).matches.map do |match|
          class_name, id = match.document.data.split('-')
          {:class => class_name, :id => id, :relevance => match.percent}
        end
      end
    end
  end
end
