module Xapit
  module Client
    class Facet
      attr_reader :name, :options
      def initialize(name, options)
        @name = name.sub(/^([a-z])/) { $1.to_s.upcase }
        @options = options.map { |option| FacetOption.new(option) }
      end
    end
  end
end
