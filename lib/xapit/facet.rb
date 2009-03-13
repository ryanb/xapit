module Xapit
  class Facet
    def initialize(blueprint, database, query)
      @blueprint = blueprint
      @database = database
      @query = query
    end
    
    def options
      matches.map do |match|
        FacetOption.new(@blueprint, match)
      end
    end
    
    def name
      @blueprint.name
    end
    
    private
    
    def matches
      enquire = Xapian::Enquire.new(@database)
      enquire.query = @query
      enquire.collapse_key = @blueprint.position
      enquire.mset(0, 1000).matches
    end
  end
end
