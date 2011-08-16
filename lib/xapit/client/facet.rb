module Xapit
  module Client
    class Facet
      attr_reader :name, :options
      def initialize(attribute, options, applied_facets = [])
        @name = attribute.to_s.gsub("_", " ").gsub(/\b([a-z])/) { $1.to_s.upcase }
        @options = options.map { |option| FacetOption.new(attribute, option, applied_facets) }
      end
    end
  end
end
