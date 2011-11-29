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
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request_post(uri.path, options.to_json)
        end
        Xapit.symbolize_keys(JSON.parse("[#{response.body}]").first) # terrible hack for handling simple objects
      end
    end
  end
end

# temporary hack to fix stack level too deep error when calling on HashWithIndifferentAccess
# class ActiveSupport::HashWithIndifferentAccess
#   def to_json(*args, &block)
#     to_hash.to_json(*args, &block)
#   end
# end
