module Xapit
  class FacetBlueprint
    attr_reader :position
    attr_reader :attribute
    
    def initialize(position, attribute, custom_name = nil)
      @position = position
      @attribute = attribute
      @custom_name = custom_name
    end
    
    def identifier_for(member)
      value = member.send(@attribute).to_s
      Digest::SHA1.hexdigest(@attribute.to_s + value)[0..6]
    end
    
    def name
      @custom_name || @attribute.to_s.humanize
    end
  end
end
