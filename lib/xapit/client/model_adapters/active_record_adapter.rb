module Xapit
  module Client
    class ActiveRecordAdapter < AbstractModelAdapter
      def self.for_class?(model_class)
        defined?(ActiveRecord::Base) && model_class <= ActiveRecord::Base
      end

      def setup
        @model_class.after_create do |member|
          member.class.xapit_index_builder.add_document(member) if Xapit.config[:enabled]
        end
        @model_class.after_update do |member|
          member.class.xapit_index_builder.update_document(member) if Xapit.config[:enabled]
        end
        @model_class.after_destroy do |member|
          member.class.xapit_index_builder.remove_document(member) if Xapit.config[:enabled]
        end
      end

      def index_all
        @model_class.find_each do |member|
          member.class.xapit_index_builder.add_document(member)
        end
      end
    end
  end
end
