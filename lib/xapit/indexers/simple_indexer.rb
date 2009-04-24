module Xapit
  class SimpleIndexer < AbstractIndexer
    def index_text_attributes(member, document)
      index_terms(text_terms_with_stemming(member), document)
    end
    
    def text_terms(member)
      @blueprint.text_attributes.map do |name, proc|
        content = member.send(name).to_s
        if proc
          proc.call(content).reject(&:blank?).map(&:to_s).map(&:downcase)
        else
          content.scan(/[a-z0-9]+/i).map(&:downcase)
        end
      end.flatten
    end
    
    def text_terms_with_stemming(member)
      text_terms(member).map do |term|
        [term, "Z#{stemmer.call(term)}"]
      end.flatten
    end
    
    def stemmer
      @stemmer ||= Xapian::Stem.new(Config.stemming)
    end
  end
end
