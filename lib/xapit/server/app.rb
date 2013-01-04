module Xapit
  module Server
    class App
      def call(env)
        request = Rack::Request.new(env)
        command = request.path[%r</xapit/(.+)>, 1]
        if Database::COMMANDS.include? command
          authorized_action(command, request.params)
        else
          render :status => 404
        end
      end

      def authorized_action(command, params)
        if Xapit.config[:access_key] && Xapit.config[:access_key] != params["access_key"]
          render :status => 403
        else
          action(command, params["json"])
        end
      end

      def action(command, json)
        data = Xapit.symbolize_keys(JSON.parse(json))
        render :content => Xapit.database(true).send(command, data).to_json
      end

      def render(options = {})
        options[:status] ||= 200
        options[:content] ||= ""
        options[:content_type] ||= "text/html"
        [options[:status], {"Content-Type" => options[:content_type]}, [options[:content]]]
      end
    end
  end
end
