require "spec_helper"

describe Xapit::Server::App do
  before(:each) do
    @app = Xapit::Server::App.new
    @request = Rack::MockRequest.new(@app)
  end

  Xapit::Server::Database::COMMANDS.each do |command|
    it "passes #{command} to database and returns response in JSON" do
      Xapit.database.stub(command.to_sym).with(:foo => "bar") { {:some => "result"} }
      response = @request.post("/xapit/#{command}", :params => {"foo" => "bar"}.to_json)
      response.status.should eq(200)
      response.body.should eq({:some => "result"}.to_json)
    end
  end

  it "responds with 404 when unknown url" do
    response = @request.post("/xapit/foo")
    response.status.should eq(404)
  end
end
