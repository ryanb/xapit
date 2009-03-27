module Xapit
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
        Digest::SHA1.hexdigest(@attribute.to_s + value.to_s)[0..6]
      end
    end
    
    def name
      @custom_name || @attribute.to_s.humanize
    end
    
    def save_facet_options_for(member)
      values_for(member).map do |value|
        option = FacetOption.new(member.class.name, @attribute.to_s, value.to_s)
        option.save
      end
    end
    
    private
    
    def values_for(member)
      value = member.send(@attribute)
      if value.kind_of? Array
        value
      else
        [value]
      end
    end
  end
end
