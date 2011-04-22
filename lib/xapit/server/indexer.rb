module Xapit
  module Server
    class Indexer
      def initialize(data)
        @data = data
      end

      def document
        document = Xapian::Document.new
        document.data = "#{@data[:class]}-#{@data[:id]}"
        @data[:text].to_s.split.each do |term|
          document.add_term(term, 1)
        end
        document
      end
    end
  end
end
