module Xapit
  module Client
    class RemoteDatabase
      def initialize(url)
        @url = url
      end

      Xapit::Server::Database::COMMANDS.each do |command|
        define_method(command) do |options|
          request(command, options)
        end
      end

      def request(command, options)
        uri = URI.parse("#{@url}/xapit/#{command}")
        response = Net::HTTP.start(uri.host, uri.port) { |http| http.request_post(uri.path, options.to_json) }
        Xapit::Server::App.symbolize_keys(JSON.parse("[#{response.body}]").first) # terrible hack for handling simple objects
      end
    end
  end
end
