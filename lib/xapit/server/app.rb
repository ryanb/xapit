module Xapit
  module Server
    class App
      def call(env)
        request = Rack::Request.new(env)
        case request.path
        when %r{/xapit/(add_document|query|spelling_suggestion)} then action($1, request.body.gets)
        else render :status => 404
        end
      end

      def action(method, json)
        data = symbolize_keys(JSON.parse(json))
        render :content => Xapit.database.send(method, data).to_json
      end

      def render(options = {})
        options[:status] ||= 200
        options[:content] ||= ""
        options[:content_type] ||= "text/html"
        [options[:status], {"Content-Type" => options[:content_type]}, [options[:content]]]
      end

      # from http://snippets.dzone.com/posts/show/11121
      def symbolize_keys(arg)
        case arg
        when Array
          arg.map { |elem| symbolize_keys(elem) }
        when Hash
          Hash[
            arg.map { |key, value|
              k = key.is_a?(String) ? key.to_sym : key
              v = symbolize_keys(value)
              [k,v]
            }]
        else
          arg
        end
      end
    end
  end
end
