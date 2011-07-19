module Xapit
  module Client
    class IndexBuilder
      attr_reader :attributes
      def initialize
        @attributes = {}
      end

      def text(*args, &block)
        add_attribute(:text, *args, &block)
      end

      def field(*args, &block)
        add_attribute(:field, *args, &block)
      end

      def sortable(*args, &block)
        add_attribute(:sortable, *args, &block)
      end

      def facet(name, custom_name = nil, &block)
        options = {}
        options[:name] = custom_name if custom_name
        add_attribute(:facet, name, options, &block)
      end

      def index(member)
        Xapit.database.add_document(index_data(member))
      end

      def index_data(member)
        data = {:class => member.class.name, :id => member.id, :attributes => {}}
        attributes.each do |name, options|
          value = member.send(name)
          value = options[:_block].call(value) if options[:_block]
          data[:attributes][name] = options.merge(:value => value)
        end
        data
      end

      def facets
        attributes.keys.select do |attribute|
          attributes[attribute][:facet]
        end
      end

      private

      def add_attribute(type, *args, &block)
        options = args.last.kind_of?(Hash) ? args.pop : {}
        args.each do |attribute|
          @attributes[attribute] ||= {}
          @attributes[attribute][type] = options
          @attributes[attribute][:_block] = block if block
        end
      end
    end
  end
end
