module Xapit
  class SimpleIndexer < AbstractIndexer
    def index_text_attributes(member, document)
      @blueprint.text_attributes.map do |name, options|
        terms_for_attribute(member, name, options).each do |term|
          document.add_term(term, options[:weight] || 1)
          database.add_spelling(term) if Config.spelling?
        end
        if Config.stemming
          stemmed_terms_for_attribute(member, name, options).each do |term|
            document.add_term(term, options[:weight] || 1)
          end
        end
      end
    end
    
    def stemmed_terms_for_attribute(member, name, options)
      terms_for_attribute(member, name, options).map do |term|
        "Z#{stemmer.call(term)}"
      end
    end
    
    def terms_for_attribute(member, name, options)
      content = member.send(name)
      if options[:proc]
        options[:proc].call(content.to_s).reject(&:blank?).map(&:to_s).map(&:downcase)
      elsif content.kind_of? Array
        content.reject(&:blank?).map(&:to_s).map(&:downcase)
      else
        content.to_s.split(/\s+/u).map { |w| w.gsub(/[^\w]/u, "") }.map(&:downcase)
      end
    end
    
    def stemmer
      @stemmer ||= Xapian::Stem.new(Config.stemming)
    end
  end
end
