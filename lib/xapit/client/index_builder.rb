module Xapit
  module Client
    class IndexBuilder
      attr_reader :attributes
      attr_reader :language

      def initialize
        @attributes = {}
        @language = Xapit.config[:stemming]
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

      def add_document(member, force_local = false)
        Xapit.database(force_local).add_document(document_data(member))
      end

      def remove_document(member, force_local = false)
        Xapit.database(force_local).remove_document(document_data(member))
      end

      def update_document(member, force_local = false)
        Xapit.database(force_local).update_document(document_data(member))
      end

      def document_data(member)
        data = {
          :class => member.class.name,
          :id => member.id,
          :attributes => {},
          :language => find_language(member)
        }

        attributes.each do |name, options|
          options = options.dup # so we can remove block without changing original hash
          value = member.send(name)
          value = options.delete(:_block).call(value) if options[:_block]
          data[:attributes][name] = options.merge(:value => value)
        end
        data
      end

      def facets
        attributes.keys.select do |attribute|
          attributes[attribute][:facet]
        end
      end

      def language(lang)
        @language = lang
      end

      private

      def find_language(member)
        lang = if @language.kind_of?(Symbol)
          member.send(@language)
        elsif @language.kind_of?(Proc)
          @language.call(member)
        else
          @language
        end

        lang || 'english'
      end

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
