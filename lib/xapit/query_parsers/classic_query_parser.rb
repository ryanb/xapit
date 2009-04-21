module Xapit
  class ClassicQueryParser < AbstractQueryParser
    def xapian_query_from_text(text)
      Xapian::QueryParser.new.parse_query(text)
    end
  end
end
