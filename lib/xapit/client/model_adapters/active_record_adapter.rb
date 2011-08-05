module Xapit
  module Client
    class ActiveRecordAdapter < AbstractModelAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      def setup
        @model_class.after_create do |record|
          record.xapit_index
        end
      end
    end
  end
end
