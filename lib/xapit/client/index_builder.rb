module Xapit
  module Client
    class IndexBuilder
      attr_reader :text_attributes
      def initialize
        @text_attributes = []
      end

      def text(*args)
        @text_attributes += args
      end
    end
  end
end
