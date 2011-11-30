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
        response = Net::HTTP.post_form(uri, :access_key => Xapit.config[:access_key], :json => options.to_json)
        Xapit.symbolize_keys(JSON.parse("[#{response.body}]").first) # terrible hack for handling simple objects
      end
    end
  end
end
