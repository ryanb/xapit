module Xapit
  module Client
    class FacetOption
      attr_reader :count, :attribute
      def initialize(attribute, option, applied_facets = [])
        @attribute = attribute
        @value = option[:value]
        @count = option[:count].to_i
        @applied_facets = applied_facets
      end

      def identifier
        Xapit.facet_identifier(@attribute, @value)
      end

      def name
        @value
      end

      def to_param
        if @applied_facets.include? identifier
          (@applied_facets - [identifier]).join('-')
        else
          (@applied_facets + [identifier]).join("-")
        end
      end
    end
  end
end
