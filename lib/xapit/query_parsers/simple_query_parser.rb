module Xapit
  class SimpleQueryParser
    attr_writer :base_query
    
    def initialize(member_class, search_text, options = {})
      @member_class = member_class
      @search_text = search_text.to_s
      @options = options
    end
    
    def query
      if (@search_text.split + condition_terms + facet_terms).empty?
        base_query
      else
        @query ||= base_query.and_query(@search_text.downcase).and_query(condition_terms + facet_terms)
      end
    end
    
    def current_page
      @options[:page] ? @options[:page].to_i : 1
    end
    
    def per_page
      @options[:per_page] ? @options[:per_page].to_i : 20
    end
    
    def sort_by_values
      if @options[:order] && @member_class
        index = @member_class.xapit_index_blueprint
        if @options[:order].kind_of? Array
          @options[:order].map do |attribute|
            index.sortable_position_for(attribute)
          end
        else
          [index.sortable_position_for(@options[:order])]
        end
      end
    end
    
    def base_query
      @base_query ||= Query.new(initial_query_string)
    end
    
    def initial_query_string
      @member_class ? "C" + @member_class.name : ""
    end
    
    def condition_terms
      if @options[:conditions]
        @options[:conditions].map do |name, value|
          "X#{name}-#{value.downcase}"
        end
      else
        []
      end
    end
    
    def facet_terms
      if @options[:facets]
        facet_identifiers.map do |identifier|
          "F#{identifier}"
        end
      else
        []
      end
    end
    
    def facet_identifiers
      @options[:facets].kind_of?(String) ? @options[:facets].split('-') : (@options[:facets] || [])
    end
  end
end
