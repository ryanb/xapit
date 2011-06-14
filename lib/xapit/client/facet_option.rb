module Xapit
  module Client
    class FacetOption
      attr_reader :count
      def initialize(attribute, option)
        @attribute = attribute
        @value = option[:value]
        @count = option[:count].to_i
      end

      def identifier
        Xapit.facet_identifier(@attribute, @value)
      end

      def name
        @value
      end
    end
  end
end
