module Xapit
  module Server
    class Indexer
      def initialize(data)
        @data = data
      end

      def document
        document = Xapian::Document.new
        document.data = "#{@data[:class]}-#{@data[:id]}"
        if @data[:texts]
          @data[:texts].each do |name, attributes|
            attributes[:value].split.each do |term|
              document.add_term(term, attributes[:weight] || 1)
            end
          end
        end
        document
      end
    end
  end
end
