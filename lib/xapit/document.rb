module Xapit
  class Document
    attr_accessor :id, :data, :terms, :term_weights, :values, :value_indexes, :spellings

    def initialize
      @terms = []
      @term_weights = []
      @values = []
      @value_indexes = []
      @spellings = []
    end

    def xapian_document
      xapian_doc = Xapian::Document.new
      xapian_doc.data = "#{id}#{data}"
      terms.each_with_index do |term, index|
        xapian_doc.add_term(term, term_weights[index] || 1)
      end
      values.each_with_index do |value, index|
        xapian_doc.add_value(value_indexes[index], value)
      end
      xapian_doc
    end

    def self.from_json(json)
      document = new
      JSON.parse(json).each do |key, value|
        document.send("#{key}=", value)
      end
      document
    end

    def to_json
      # TODO
    end
  end
end
