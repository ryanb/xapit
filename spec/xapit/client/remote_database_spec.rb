require "spec_helper"

describe Xapit::Client::RemoteDatabase do
  before(:each) do
    @database = Xapit::Client::RemoteDatabase.new("http://localhost:1234")
  end

  Xapit::Server::Database::COMMANDS.each do |command|
    it "passes #{command} to remote server using Net::HTTP" do
      Xapit.config[:access_key] = "abc123"
      http = Object.new
      response = Object.new
      uri = URI.parse("http://localhost:1234/xapit/#{command}")
      Net::HTTP.should_receive(:post_form).with(uri, :access_key => "abc123", :json => {:send => "request"}.to_json).and_return(response)
      response.should_receive(:body).and_return({"receive" => "response"}.to_json)
      @database.send(command, :send => "request").should eq(:receive => "response")
    end
  end
end
