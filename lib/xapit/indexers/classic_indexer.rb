module Xapit
  class ClassicIndexer < AbstractIndexer
    def index_text_attributes(member, document)
      term_generator.document = document
      @blueprint.text_attributes.each do |name, proc|
        # currently no support for proc option
        term_generator.index_text(member.send(name).to_s)
      end
    end
    
    def term_generator
      @term_generator ||= create_term_generator
    end
    
    def create_term_generator
      term_generator = Xapian::TermGenerator.new
      term_generator.set_flags(Xapian::TermGenerator::FLAG_SPELLING, 0)
      term_generator.database = database
      term_generator.stemmer = Xapian::Stem.new("english")
      term_generator
    end
  end
end
