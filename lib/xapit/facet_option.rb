module Xapit
  class FacetOption
    def initialize(match, blueprint)
      @match = match
      @blueprint = blueprint
    end
    
    def name
      class_name, id = @match.document.data.split('-')
      record = class_name.constantize.find(id)
      record.send(@blueprint.attribute).to_s
    end
  end
end
