module Xapit
  class FacetOption
    def initialize(blueprint, match)
      @blueprint = blueprint
      @match = match
    end
    
    def name
      class_name, id = @match.document.data.split('-')
      record = class_name.constantize.find(id)
      record.send(@blueprint.attribute).to_s
    end
    
    def count
      # add one because Xapian counts the collapse record as one
      @match.collapse_count + 1
    end
  end
end
