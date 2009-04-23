module Xapit
  class SimpleIndexer < AbstractIndexer
    def index_text_attributes(member, document)
      text_terms(member).each do |term|
        document.add_term(term)
        database.add_spelling(term)
      end
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
  end
end
