module Xapit
  class ClassicQueryParser < AbstractQueryParser
    def xapian_query_from_text(text)
      xapian_parser.parse_query(cleanup_text(text), Xapian::QueryParser::FLAG_WILDCARD | Xapian::QueryParser::FLAG_PHRASE | Xapian::QueryParser::FLAG_BOOLEAN | Xapian::QueryParser::FLAG_LOVEHATE)
    end

    def xapian_parser
      @xapian_parser ||= build_xapian_parser
    end

    def cleanup_text(text)
      text.gsub(/\b([a-z])\*/i, "\\1").gsub(/[^\w\*\s:]/u, "")
    end

    def build_xapian_parser
      parser = Xapian::QueryParser.new
      parser.database = Config.database.xapian_database
      parser.stemmer = Xapian::Stem.new(Config.stemming)
      parser.stemming_strategy = Xapian::QueryParser::STEM_SOME
      parser.default_op = Xapian::Query::OP_AND
      if @member_class
        @member_class.xapit_index_blueprint.field_attributes.each do |field|
          parser.add_prefix(field.to_s, "X#{field}-")
        end
      end
      parser
    end
  end
end
