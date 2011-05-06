module Xapit
  module Client
    class Collection
      attr_reader :query
      def initialize(query = [])
        @query = query
      end

      def in_classes(*classes)
        scope(:in_classes, classes)
      end

      def search(phrase = nil)
        if phrase && !phrase.empty?
          scope(:search, phrase)
        else
          self
        end
      end

      def where(conditions)
        scope(:where, conditions)
      end

      def not_where(conditions)
        scope(:not_where, conditions)
      end

      def or_where(conditions)
        scope(:or_where, conditions)
      end

      def order(column, direction = :asc)
        scope(:order, [column, direction])
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
