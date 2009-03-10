module Xapit
  class IndexBlueprint
    attr_reader :text_attributes
    attr_reader :field_attributes
    
    def initialize
      @text_attributes = []
      @field_attributes = []
    end
    
    def text(*attributes)
      @text_attributes += attributes
    end
    
    def field(*attributes)
      @field_attributes += attributes
    end
    
    def stripped_words(content)
      content.to_s.downcase.scan(/[a-z0-9]+/)
    end
    
    def terms(member)
      field_terms(member) + text_terms(member)
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
  end
end
