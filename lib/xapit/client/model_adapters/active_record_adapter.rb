module Xapit
  module Client
    class ActiveRecordAdapter < AbstractModelAdapter
      def self.for_class?(model_class)
        model_class <= ActiveRecord::Base
      end

      def setup
        @model_class.after_create do |record|
          record.class.xapit_index_builder.add_document(record)
        end
        @model_class.after_destroy do |record|
          record.class.xapit_index_builder.remove_document(record)
        end
      end
    end
  end
end
