module Xapit
  module Membership
    def self.included(base)
      base.extend ClassMethods
      base.send(:attr_accessor, :xapit_relevance) # is there a better way to do this?
    end
    
    module ClassMethods
      def search(*args)
        Collection.new(self, *args)
      end
      
      def xapit(*args)
        @xapit_index_blueprint = IndexBlueprint.new(self, *args)
        yield(@xapit_index_blueprint)
      end
      
      def xapit_index_blueprint
        @xapit_index_blueprint
      end
      
      def xapit_facet_blueprint(attribute)
        result = @xapit_index_blueprint.facets.detect { |f| f.attribute.to_s == attribute.to_s }
        raise "Unable to find facet blueprint for #{attribute} on #{name}" if result.nil?
        result
      end
    end
  end
end
