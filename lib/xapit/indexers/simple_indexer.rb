module Xapit
  class SimpleIndexer < AbstractIndexer
    def index_text_attributes(member, document)
      @blueprint.text_attributes.map do |name, options|
        terms_for_attribute(member, name, options).each do |term|
          document.add_term(term, options[:weight] || 1)
          database.add_spelling(term) if Config.spelling?
        end
      end
    end
    
    def terms_for_attribute(member, name, options)
      terms_for_attribute_without_stemming(member, name, options).map do |term|
        [term, "Z#{stemmer.call(term)}"]
      end.flatten
    end
    
    def terms_for_attribute_without_stemming(member, name, options)
      content = member.send(name).to_s
      if options[:proc]
        options[:proc].call(content).reject(&:blank?).map(&:to_s).map(&:downcase)
      else
        content.scan(/\w+/u).map(&:downcase)
      end
    end
    
    def stemmer
      @stemmer ||= Xapian::Stem.new(Config.stemming)
    end
  end
end
