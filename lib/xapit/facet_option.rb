module Xapit
  class FacetOption
    def initialize(blueprint, match)
      @blueprint = blueprint
      @match = match
    end
    
    def name
      class_name, id = @match.document.data.split('-')
      record.send(@blueprint.attribute).to_s
    end
    
    def count
      # add one because Xapian counts the collapsed record as one
      @match.collapse_count + 1
    end
    
    def identifier
      @blueprint.identifier_for(record)
    end
    
    private
    
    def record
      # TODO cache record fetching?
      class_name, id = @match.document.data.split('-')
      class_name.constantize.find(id)
    end
  end
end
