module Xapit
  class ClassicQueryParser < AbstractQueryParser
    def xapian_query_from_text(text)
      xapian_parser.parse_query(text)
    end
    
    def xapian_parser
      @xapian_parser ||= build_xapian_parser
    end
    
    def build_xapian_parser
      parser = Xapian::QueryParser.new
      parser.stemmer = Xapian::Stem.new(Config.stemming)
      parser.stemming_strategy = Xapian::QueryParser::STEM_SOME
      parser.default_op = Xapian::Query::OP_AND
      parser
    end
  end
end
