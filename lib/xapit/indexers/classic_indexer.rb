module Xapit
  class ClassicIndexer < AbstractIndexer
    def index_text_attributes(member, document)
      term_generator.document = document
      @blueprint.text_attributes.each do |name, options|
        content = member.send(name)
        if options[:proc]
          index_terms(options[:proc].call(content.to_s).reject(&:blank?).map(&:to_s).map(&:downcase), document)
        elsif content.kind_of? Array
          index_terms(content.reject(&:blank?).map(&:to_s).map(&:downcase), document)
        else
          term_generator.index_text(content.to_s)
        end
      end
    end
    
    def term_generator
      @term_generator ||= create_term_generator
    end
    
    def create_term_generator
      term_generator = Xapian::TermGenerator.new
      term_generator.set_flags(Xapian::TermGenerator::FLAG_SPELLING, 0) if Config.spelling?
      term_generator.database = database
      term_generator.stemmer = Xapian::Stem.new(Config.stemming)
      term_generator
    end
  end
end
