module Xapit
  class Server
    def call(env)
      request = Rack::Request.new(env)
      if request.path == "/xapit/documents"
        case request.request_method
        when "POST" then add_document(request.params)
        when "PUT" then update_document(request.params)
        when "DELETE" then delete_document(request.params)
        end
      else
        render :status => 404
      end
    end

    def add_document(params)
      document = Document.from_json(params["document"])
      Config.database.add_document(document)
      render
    end

    def update_document(params)
      document = Document.from_json(params["document"])
      Config.database.replace_document("Q#{document.data}", document)
      render
    end

    def delete_document(params)
      document = Document.from_json(params["document"])
      Config.database.delete_document("Q#{document.data}")
      render
    end

    def render(options = {})
      options[:status] ||= 200
      options[:content] ||= ""
      options[:content_type] ||= "text/html"
      [options[:status], {"Content-Type" => options[:content_type]}, [options[:content]]]
    end
  end
end
