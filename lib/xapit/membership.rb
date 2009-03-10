module Xapit
  module Membership
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def xapit
        @xapit_index_blueprint = IndexBlueprint.new
        yield(@xapit_index_blueprint)
      end
      
      def xapit_index_blueprint
        @xapit_index_blueprint
      end
    end
  end
end