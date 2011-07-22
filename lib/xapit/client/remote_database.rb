module Xapit
  module Client
    class RemoteDatabase
      def initialize(url)
        @url = url
      end

      def query(options)
        request("query", options)
      end

      def spelling_suggestion(options)
        request("spelling_suggestion", options)
      end

      def add_document(options)
        request("add_document", options)
      end

      def request(command, options)
        uri = URI.parse("#{@url}/xapit/#{command}")
        response = Net::HTTP.post_form(uri, options.to_json)
        Xapit::Server::App.symbolize_keys(JSON.parse(response))
      end
    end
  end
end
