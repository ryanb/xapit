module Xapit
  module Client
    class IndexBuilder
      attr_reader :text_attributes
      def initialize
        @text_attributes = {}
      end

      def text(*args)
        options = args.last.kind_of?(Hash) ? args.pop : {}
        args.each do |attribute|
          @text_attributes[attribute] = options
        end
      end
    end
  end
end
