module Xapit
  module Server
    class Indexer
      def initialize(data)
        @data = data
      end

      def document
        document = Xapian::Document.new
        document.data = "#{@data[:class]}-#{@data[:id]}"
        if @data[:attributes]
          @data[:attributes].each do |name, options|
            if options[:text]
              options[:value].split.each do |term|
                document.add_term(term, options[:text][:weight] || 1)
              end
            end
          end
        end
        document
      end
    end
  end
end
