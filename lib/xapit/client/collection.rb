module Xapit
  module Client
    class Collection
      attr_reader :query
      def initialize(query = [])
        @query = query
      end

      def in_classes(*args)
        scope(:in_classes, args)
      end

      def search(*args)
        scope(:search, args)
      end

      def where(*args)
        scope(:where, args)
      end

      def order(*args)
        scope(:order, args)
      end

      def records
        @records ||= fetch_records
      end

      def respond_to?(method, include_private = false)
        Array.method_defined?(method) || super
      end

      private

      def scope(type, args)
        Collection.new(@query + [{type => args}])
      end

      def fetch_records
        Xapit.database.query(@query).map do |result|
          Kernel.const_get(result[:class]).find(result[:id])
        end
      end

      def method_missing(method, *args, &block)
        if Array.method_defined?(method)
          records.send(method, *args, &block)
        else
          super
        end
      end
    end
  end
end
