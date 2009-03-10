module Xapit
  class IndexBlueprint
    attr_reader :text_attributes
    
    def initialize
      @text_attributes = []
    end
    
    def text(*attributes)
      @text_attributes += attributes
    end
    
    def stripped_words(content)
      content.to_s.downcase.scan(/[a-z0-9]+/)
    end
    
    def terms(member)
      text_attributes.map do |name|
        stripped_words(member.send(name))
      end.flatten
    end
  end
end
