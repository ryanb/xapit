module Xapit
  module Server
    class Indexer
      def initialize(data)
        @data = data
      end

      def document
        document = Xapian::Document.new
        document.data = "#{@data[:class]}-#{@data[:id]}"
        terms.each do |term, weight|
          document.add_term(term, weight)
          Xapit.database.xapian_database.add_spelling(term, weight)
        end
        values.each do |index, value|
          document.add_value(index, value)
        end
        document
      end

      def terms
        base_terms + text_terms + field_terms
      end

      def values
        values = {}
        each_value do |type, name, value, options|
          values[Xapit.value_index(type, name)] = Xapit.serialize_value(value)
        end
        values
      end

      def text_terms
        each_attribute(:text) do |name, value, options|
          value.to_s.downcase.split.map do |term|
            [term, options[:weight] || 1]
          end
        end.flatten(1)
      end

      def field_terms
        each_attribute(:field) do |name, value, options|
          ["X#{name}-#{parse_field(value)}", 1]
        end
      end

      private

      def base_terms
        [["C#{@data[:class]}", 1], ["Q#{@data[:class]}-#{@data[:id]}", 1]]
      end

      def parse_field(value)
        if value.kind_of? Time
          value.to_i
        else
          value.to_s.downcase
        end
      end

      def each_value
        each_attribute(:field) do |name, value, options|
          yield(:field, name, value, options)
        end
        each_attribute(:sortable) do |name, value, options|
          yield(:sortable, name, value, options)
        end
      end

      def each_attribute(type)
        if @data[:attributes]
          @data[:attributes].map do |name, options|
            if options.has_key? type
              if options[:value].kind_of? Array
                options[:value].map { |value| yield(name, value, options[type]) }
              else
                [yield(name, options[:value], options[type])]
              end
            end
          end.compact.flatten(1)
        else
          []
        end
      end
    end
  end
end
