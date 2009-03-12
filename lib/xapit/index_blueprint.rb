module Xapit
  class IndexBlueprint
    attr_reader :text_attributes
    attr_reader :field_attributes
    attr_reader :facet_attributes
    
    def initialize(member_class)
      @member_class = member_class
      @text_attributes = []
      @field_attributes = []
      @facet_attributes = []
    end
    
    def text(*attributes)
      @text_attributes += attributes
    end
    
    def field(*attributes)
      @field_attributes += attributes
    end
    
    def facet(*attributes)
      @facet_attributes += attributes
      field(*attributes)
    end
    
    def document_for(member)
      document = Xapian::Document.new
      document.data = "#{member.class}-#{member.id}"
      terms(member).each do |term|
        document.add_term(term)
      end
      values(member).each_with_index do |value, index|
        document.add_value(index, value)
      end
      document
    end
    
    def stripped_words(content)
      content.to_s.downcase.scan(/[a-z0-9]+/)
    end
    
    def terms(member)
      base_terms(member) + field_terms(member) + text_terms(member)
    end
    
    def base_terms(member)
      ["C#{member.class}", "Q#{member.class}-#{member.id}"]
    end
    
    def text_terms(member)
      text_attributes.map do |name|
        stripped_words(member.send(name))
      end.flatten
    end
    
    def field_terms(member)
      field_attributes.map do |name|
        "X#{name}-#{member.send(name).to_s.downcase}"
      end
    end
    
    def values(member)
      facet_attributes.map do |name|
        member.send(name).to_s
      end
    end
    
    def index_into_database(db)
      @member_class.each do |member|
        db.add_document(document_for(member))
      end
    end
  end
end
