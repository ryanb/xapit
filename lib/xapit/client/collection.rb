module Xapit
  module Client
    class Collection
      DEFAULT_PER_PAGE = 20

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
        phrase && !phrase.empty? ? scope(:search, phrase) : self
      end

      def or_search(phrase = nil)
        phrase && !phrase.empty? ? scope(:or_search, phrase) : self
      end

      def not_search(phrase = nil)
        phrase && !phrase.empty? ? scope(:not_search, phrase) : self
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

      def per_page(per_page)
        scope(:per_page, per_page)
      end

      def similar_to(member)
        scope(:similar_to, member.class.xapit_index_builder.document_data(member))
      end

      def with_facets(facets)
        facets.to_s.length.zero? ? self : scope(:with_facets, facets.split("-"))
      end

      def include_facets(*facets)
        facets.empty? ? self : scope(:include_facets, facets)
      end

      def records
        @records ||= query[:records].map do |record|
          member = Kernel.const_get(record[:class]).find(record[:id])
          member.xapit_relevance = record[:relevance]
          member
        end
      end

      # TODO use a better delegation technique
      def ==(other)
        records == other
      end

      def eql?(other)
        records.eql? other
      end

      def equal?(other)
        records.equal? other
      end

      def total_entries
        query[:total].to_i
      end

      def current_page
        (clause_value(:page) || 1).to_i
      end

      def previous_page
        current_page - 1 if current_page > 1
      end

      def next_page
        current_page + 1 if current_page < num_pages
      end

      def limit_value
        (clause_value(:per_page) || DEFAULT_PER_PAGE).to_i
      end

      def num_pages
        (total_entries.to_f / limit_value).ceil
      end
      alias_method :total_pages, :num_pages

      def applied_facet_options
        query[:applied_facet_options].map do |option|
          FacetOption.new(option[:name], {:value => option[:value]}, applied_facet_identifiers)
        end
      end

      def applied_facet_identifiers
        query[:applied_facet_options].map { |option| option[:id] }
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

      def scope(type, args)
        Collection.new(@clauses + [{type => args}])
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
        applied_facets = applied_facet_options.map(&:identifier)
        query[:facets].map { |attribute, options| Facet.new(attribute, filter_facet_options(options), applied_facets) }
      end

      def filter_facet_options(options)
        options.select do |option|
          option[:count].to_i < total_entries
        end
      end

      def clause_value(key)
        clauses.map { |clause| clause[key] }.compact.last
      end

      def query
        @query ||= Xapit.database.query(@clauses)
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
