module Xapit
  class Facet
    def initialize(blueprint, database, query, existing_facet_identifiers)
      @blueprint = blueprint
      @database = database
      @query = query
      @existing_facet_identifiers = existing_facet_identifiers
    end
    
    def options
      matches.map do |match|
        FacetOption.new(@blueprint, match, @existing_facet_identifiers)
      end.sort_by(&:name)
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
