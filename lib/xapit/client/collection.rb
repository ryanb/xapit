module Xapit
  module Client
    class Collection
      attr_reader :clauses
      def initialize(clauses = [])
        @clauses = clauses
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

      def page(page_num)
        scope(:page, page_num)
      end

      def per(per_page)
        scope(:per_page, per_page)
      end

      def similar_to(member)
        scope(:similar_to, member.class.xapit_index_builder.index_data(member))
      end

      def match_facets(facets)
        scope(:match_facets, facets.split("-"))
      end

      def include_facets(*facets)
        facets.empty? ? self : scope(:include_facets, facets)
      end

      def records
        @records ||= query[:records].map { |record| Kernel.const_get(record[:class]).find(record[:id]) }
      end

      def total_entries
        query[:total].to_i
      end

      def facets
        @facets ||= fetch_facets.select { |f| f.options.size > 1 }
      end

      def spelling_suggestion
        @spelling_suggestion ||= Xapit.database.spelling_suggestion(@clauses)
      end

      def respond_to?(method, include_private = false)
        Array.method_defined?(method) || super
      end

      private

      def fetch_facets
        query[:facets].map { |attribute, options| Facet.new(attribute, options) }
      end

      def query
        @query ||= Xapit.database.query(@clauses)
      end

      def scope(type, args)
        Collection.new(@clauses + [{type => args}])
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
