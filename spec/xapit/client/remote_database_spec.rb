require "spec_helper"

describe Xapit::Client::RemoteDatabase do
  before(:each) do
    @database = Xapit::Client::RemoteDatabase.new("http://localhost:1234")
  end

  %w[query add_document spelling_suggestion].each do |command|
    it "passes #{command} to remote server using Net::HTTP" do
      http = Object.new
      response = Object.new
      uri = URI.parse("http://localhost:1234/xapit/#{command}")
      Net::HTTP.should_receive(:start).with(uri.host, uri.port).and_yield(http)
      http.should_receive(:request_post).with(uri.path, {:send => "request"}.to_json).and_return(response)
      response.should_receive(:body).and_return({"receive" => "response"}.to_json)
      @database.send(command, :send => "request").should eq(:receive => "response")
    end
  end
end
