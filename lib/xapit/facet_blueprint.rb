module Xapit
  class FacetBlueprint
    def initialize(name)
      @name = name
    end
    
    def identifier_for(member)
      option = FacetOption.new
      option.name = member.send(@name).to_s
      option.identifier
    end
  end
end
