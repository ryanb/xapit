module Xapit
  module Client
    class FacetOption
      attr_reader :name, :count
      def initialize(option)
        @name = option[:value]
        @count = option[:count]
      end
    end
  end
end
