module Xapit
  module Server
    class Query
      def initialize(query)
        @query = query
      end

      def results
        enquire = Xapian::Enquire.new(Xapit.database.xapian_database)
        enquire.query = Xapian::Query.new(Xapian::Query::OP_AND, [@query.first ? @query.first[:search].first : ""])
        enquire.mset(0, 200).matches.map do |match|
          class_name, id = match.document.data.split('-')
          {:class => class_name, :id => id, :relevance => match.percent}
        end
      end
    end
  end
end
