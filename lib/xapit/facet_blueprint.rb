module Xapit
  class FacetBlueprint
    attr_reader :position
    
    def initialize(position, attribute)
      @position = position
      @attribute = attribute
    end
    
    def identifier_for(member)
      value = member.send(@attribute).to_s
      Digest::SHA1.hexdigest(@attribute.to_s + value)[0..6]
    end
  end
end
