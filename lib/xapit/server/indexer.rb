module Xapit
  module Server
    class Indexer
      def initialize(data)
        @data = data
      end

      def database
        Xapit.database.xapian_database
      end

      def document
        document = Xapian::Document.new
        document.data = id
        terms.each { |term, weight| document.add_term(term, weight) }
        text_terms.each { |term, weight| database.add_spelling(term, weight) } if Xapit.config[:spelling]
        values.each { |index, value| document.add_value(index, value) }
        save_facets
        document
      end

      def id
        "#{@data[:class]}-#{@data[:id]}"
      end

      def id_term
        "Q#{id}"
      end

      def terms
        base_terms + text_terms + stemmed_text_terms + field_terms + facet_terms
      end

      def values
        values = {}
        each_value do |index, value|
          if values[index]
            values[index] += "\3#{value}" # multiple values are split back out on the query side
          else
            values[index] = value
          end
        end
        values
      end

      def text_terms
        terms = []
        each_attribute(:text) do |name, value, options|
          words = value
          words = value.to_s.split(/\s+/u) unless value.kind_of? Array

          weight = options[:weight] || 1
          words.each do |word|
            next if word.empty? || word.bytesize >= 245

            word.downcase!

            terms << [word, weight]
            terms << stemmed_term(word, weight)

            clean_word = ActiveSupport::Multibyte::Chars.new(word).normalize(:kd).gsub(/[^\w]/u, "").to_s
            if !clean_word.empty? && clean_word != word
              terms << [clean_word, weight]
              terms << stemmed_term(clean_word, weight)
            end
          end
        end

        terms.uniq
      end

      # TODO refactor with stemmed_text_terms
      def stemmed_text_terms
        if stemmer = build_stemmer
          each_attribute(:text) do |name, value, options|
            value = value.to_s.split(/\s+/u).map { |w| w.gsub(/[^\w]/u, "") } unless value.kind_of? Array
            value.map(&:to_s).map(&:downcase).map do |term|
              ["Z#{stemmer.call(term)}", options[:weight] || 1] unless term.empty?
            end
          end.flatten(1).compact
        else
          []
        end
      end

      def field_terms
        each_attribute(:field) do |name, value, options|
          ["X#{name}-#{parse_field(value)}", 1]
        end
      end

      def facet_terms
        each_attribute(:facet) do |name, value, options|
          ["F#{Xapit.facet_identifier(name, value)}", 1]
        end
      end

      def save_facets
        each_attribute(:facet) do |name, value, options|
          id = Xapit.facet_identifier(name, value)
          unless database.term_exists("Xid-#{id}")
            document = Xapian::Document.new
            document.data = "#{name}|||#{value}"
            document.add_term("CFacetOption")
            document.add_term("Xid-#{id}")
            database.add_document(document)
          end
        end
      end

      private

      def build_stemmer
        begin
          Xapian::Stem.new(@data[:language])
        rescue ArgumentError
          return nil
        end
      end

      def stemmed_term(word, weight = 1)
        term = [word, weight]
        if stemmer = build_stemmer
          stemmed = stemmer.call(word)
          term = ["Z#{word}", weight] if stemmed != word
        end

        term
      end

      def base_terms
        [["C#{@data[:class]}", 1], [id_term, 1]]
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
          yield(Xapit.value_index(:field, name), Xapit.serialize_value(value))
        end
        each_attribute(:sortable) do |name, value, options|
          yield(Xapit.value_index(:sortable, name), Xapit.serialize_value(value))
        end
        each_attribute(:facet) do |name, value, options|
          yield(Xapit.value_index(:facet, name), value.to_s)
        end
      end

      def each_attribute(type)
        if @data[:attributes]
          @data[:attributes].map do |name, options|
            if options.has_key? type
              if options[:value].kind_of?(Array) && type != :text
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
