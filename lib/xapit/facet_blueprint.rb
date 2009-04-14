module Xapit
  # A facet blueprint keeps track of the settings for indexing a given facet. You can specify a custom
  # name for a given facet by providing a second argument when defining.
  #
  #   xapit do |index|
  #     index.facet :category_name, "Category"
  #   end
  #
  # Multiple facet values are supported for a single record. All you need to do is return an array of
  # values instead of a single string.
  # 
  #   def category_names
  #     categories.map(&:name) # => ["Toys", "Clothing"]
  #   end
  # 
  class FacetBlueprint
    attr_reader :member_class
    attr_reader :position
    attr_reader :attribute
    
    def initialize(member_class, position, attribute, custom_name = nil)
      @member_class = member_class
      @position = position
      @attribute = attribute
      @custom_name = custom_name
    end
    
    def identifiers_for(member)
      values_for(member).map do |value|
        Digest::SHA1.hexdigest(@attribute.to_s + value)[0..6]
      end
    end
    
    # The name of the facet. This will return the custom name if given while setting up the index,
    # or default to humanizing the attribute name.
    def name
      @custom_name || @attribute.to_s.humanize
    end
    
    def save_facet_options_for(member)
      values_for(member).map do |value|
        option = FacetOption.new(member.class.name, @attribute.to_s, value)
        option.save
      end
    end
    
    private
    
    def values_for(member)
      value = member.send(@attribute)
      if value.kind_of? Array
        value.map(&:to_s).reject(&:empty?)
      else
        [value].map(&:to_s).reject(&:empty?)
      end
    end
  end
end

