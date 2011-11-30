require "spec_helper"

describe Xapit::Server::App do
  before(:each) do
    @app = Xapit::Server::App.new
    @request = Rack::MockRequest.new(@app)
  end

  Xapit::Server::Database::COMMANDS.each do |command|
    it "passes #{command} to database and returns response in JSON" do
      Xapit.database.stub(command.to_sym).with(:foo => "bar") { {:some => "result"} }
      response = @request.post("/xapit/#{command}", :params => {:json => {"foo" => "bar"}.to_json})
      response.status.should eq(200)
      response.body.should eq({:some => "result"}.to_json)
    end
  end

  it "responds with 404 when unknown url" do
    response = @request.post("/xapit/foo")
    response.status.should eq(404)
  end

  it "responds with 403 when access key is provided and not matched" do
    Xapit.config[:access_key] = "secret"
    response = @request.post("/xapit/query", :params => {:access_key => "nomatch", :json => "[]"})
    response.status.should eq(403)
  end

  it "responds when access key is provided and matched" do
    Xapit.config[:access_key] = "abc123"
    Xapit.database.should_receive(:query).with([])
    response = @request.post("/xapit/query", :params => {:access_key => "abc123", :json => "[]"})
    response.status.should eq(200)
  end
end
