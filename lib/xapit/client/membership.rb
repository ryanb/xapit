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
          include AdditionalMethods unless include?(AdditionalMethods)
        end
      end

      module AdditionalMethods
        def self.included(base)
          base.extend ClassMethods
          base.xapit_model_adapter.setup
          base.send(:attr_accessor, :xapit_relevance)
        end

        module ClassMethods
          def xapit_model_adapter
            @xapit_model_adapter ||= Xapit::Client::AbstractModelAdapter.adapter_class(self).new(self)
          end

          def xapit_index_builder
            @xapit_index_builder
          end

          def xapit_search(*args)
            Collection.new.in_classes(self).include_facets(*xapit_index_builder.facets).search(*args)
          end

          def search(*args)
            xapit_search(*args)
          end
        end

        def search_similar(*args)
          self.class.search(*args).similar_to(self)
        end
      end
    end
  end
end
