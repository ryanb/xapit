module Xapit
  module Server
    class Indexer
      def initialize(data)
        @data = data
      end

      def document
        document = Xapian::Document.new
        document.data = "#{@data[:class]}-#{@data[:id]}"
        weighted_terms.each do |term, weight|
          document.add_term(term, weight)
        end
        terms.each do |term|
          document.add_term(term, 1)
        end
        values.each do |identifier, value|
          document.add_value(Xapit.value_index(identifier), value)
        end
        document
      end

      def terms
        ["C#{@data[:class]}", "Q#{@data[:class]}-#{@data[:id]}"] + field_terms
      end

      def weighted_terms
        each_attribute(:text) do |name, value, options|
          value.split.map do |term|
            [term, options[:weight] || 1]
          end
        end.flatten(1)
      end

      private

      def field_terms
        each_attribute(:field) do |name, value, options|
          "X#{name}-#{value.downcase}"
        end
      end

      def each_attribute(type)
        if @data[:attributes]
          @data[:attributes].map do |name, options|
            if options.has_key? type
              yield(name, options[:value], options[type])
            end
          end.compact
        else
          []
        end
      end
    end
  end
end
