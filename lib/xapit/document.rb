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
  end
end
