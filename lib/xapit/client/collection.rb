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

      def not_in_classes(*classes)
        scope(:not_in_classes, classes)
      end

      def search(phrase = nil)
        if phrase && !phrase.empty?
          scope(:search, phrase)
        else
          self
        end
      end

      def where(conditions)
        scope(:where, where_conditions(conditions))
      end

      def not_where(conditions)
        scope(:not_where, where_conditions(conditions))
      end

      def or_where(conditions)
        scope(:or_where, where_conditions(conditions))
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
        scope(:similar_to, member.class.xapit_index_builder.document_data(member))
      end

      def with_facets(facets)
        scope(:with_facets, facets.split("-")) if facets.to_s.length > 0
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

      def applied_facet_options
        query[:applied_facet_options]
      end

      def facets
        @facets ||= fetch_facets.select { |f| f.options.size > 0 }
      end

      def spelling_suggestion
        @spelling_suggestion ||= Xapit.database.spelling_suggestion(@clauses)
      end

      def respond_to?(method, include_private = false)
        Array.method_defined?(method) || super
      end

      private

      def where_conditions(conditions)
        conditions.keys.each do |key|
          if conditions[key].kind_of? Range
            conditions[key] = {:from => conditions[key].begin, :to => conditions[key].end}
          end
        end
        conditions
      end

      def fetch_facets
        query[:facets].map { |attribute, options| Facet.new(attribute, filter_facet_options(options)) }
      end

      def filter_facet_options(options)
        options.select do |option|
          option[:count].to_i < total_entries
        end
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
