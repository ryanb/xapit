module Xapit
  module Client
    class AbstractModelAdapter
      def self.inherited(subclass)
        @@subclasses ||= []
        @@subclasses << subclass
      end

      def self.adapter_class(model_class)
        @@subclasses.detect { |subclass| subclass.for_class?(model_class) } || DefaultModelAdapter
      end

      def self.for_class?(model_class)
        false # override in subclass
      end

      def setup
        # override in subclass
      end

      def initialize(model_class)
        @model_class = model_class
      end
    end
  end
end
