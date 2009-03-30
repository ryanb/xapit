module Xapit
  # Facets allow users to further filter the result set based on certain attributes.
  # You should fetch facets by calling "facets" on a Xapit::Collection search result.
  # 
  # <% for facet in @articles.facets %>
  #   <%= facet.name %>
  #   <% for option in facet.options %>
  #     <%= link_to option.name, :overwrite_params => { :facets => option }) %>
  #     (<%= option.count %>)
  #   <% end %>
  # <% end %>
  #
  # See Xapit::FacetBlueprint for details on how to index a facet.
  class Facet
    attr_accessor :existing_facet_identifiers
    
    def initialize(blueprint, query, existing_facet_identifiers)
      @blueprint = blueprint
      @query = query.dup
      @existing_facet_identifiers = existing_facet_identifiers
    end
    
    # Xapit::FacetOption objects for this facet. This only lists the ones which match the current query.
    def options
      matching_identifiers.map do |identifier, count|
        option = FacetOption.find(identifier)
        option.count = count
        option.existing_facet_identifiers = @existing_facet_identifiers
        option
      end.sort_by(&:name)
    end
    
    def matching_identifiers
      result = {}
      matches.each do |match|
        class_name, id = match.document.data.split('-')
        record = class_name.constantize.find(id)
        @blueprint.identifiers_for(record).each do |identifier|
          unless existing_facet_identifiers.include? identifier
            result[identifier] ||= 0
            result[identifier] += (match.collapse_count + 1)
          end
        end
      end
      result
    end
    
    # The name of the facet. See Xapit::FacetBlueprint for details.
    def name
      @blueprint.name
    end
    
    private
    
    def matches
      @query.matches(0, 1000, :collapse_key => @blueprint.position)
    end
  end
end
