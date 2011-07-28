module Xapit
  module Client
    class ActiveRecordAdapter < AbstractModelAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end
    end
  end
end
