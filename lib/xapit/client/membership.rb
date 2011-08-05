module Xapit
  module Client
    module Membership
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def xapit(&block)
          @xapit_index_builder = IndexBuilder.new
          @xapit_index_builder.instance_eval(&block)
          include AdditionalMethods
          xapit_model_adapter.setup
        end

        def xapit_model_adapter
          @xapit_model_adapter ||= Xapit::Client::AbstractModelAdapter.adapter_class(self).new(self)
        end
      end

      module AdditionalMethods
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def xapit_index_builder
            @xapit_index_builder
          end

          def search(*args)
            Collection.new.in_classes(self).include_facets(*xapit_index_builder.facets).search(*args)
          end
        end

        def xapit_index
          self.class.xapit_index_builder.index(self)
        end

        def search_similar(*args)
          self.class.search(*args).similar_to(self)
        end
      end
    end
  end
end

if defined? ActiveRecord
  ActiveRecord::Base.class_eval do
    include Xapit::Client::Membership
  end
end
