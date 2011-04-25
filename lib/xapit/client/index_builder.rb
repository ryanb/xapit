module Xapit
  module Client
    class IndexBuilder
      attr_reader :attributes
      def initialize
        @attributes = {}
      end

      def text(*args)
        add_attribute(:text, *args)
      end

      def field(*args)
        add_attribute(:field, *args)
      end

      def sortable(*args)
        add_attribute(:sortable, *args)
      end

      def facet(name, custom_name = nil)
        options = {}
        options[:name] = custom_name if custom_name
        add_attribute(:facet, name, options)
      end

      def index(member)
        Xapit.database.add_document(index_data(member))
      end

      def index_data(member)
        data = {:class => member.class.name, :id => member.id, :attributes => {}}
        attributes.each do |name, options|
          data[:attributes][name] = options.merge(:value => member.send(name))
        end
        data
      end

      private

      def add_attribute(type, *args)
        options = args.last.kind_of?(Hash) ? args.pop : {}
        args.each do |attribute|
          @attributes[attribute] ||= {}
          @attributes[attribute][type] = options
        end
      end
    end
  end
end
