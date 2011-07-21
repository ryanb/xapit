require "spec_helper"

describe Xapit::Server::App do
  before(:each) do
    @app = Xapit::Server::App.new
    @request = Rack::MockRequest.new(@app)
  end

  it "passes add_document to database" do
    Xapit.database.stub(:add_document).with(:foo => "bar")
    response = @request.post("/xapit/add_document", :params => {"foo" => "bar"}.to_json)
    response.status.should == 200
  end

  it "passes query to database and returns response in JSON" do
    Xapit.database.stub(:query).with(:foo => "bar") { {:some => "result"} }
    response = @request.post("/xapit/query", :params => {"foo" => "bar"}.to_json)
    response.status.should == 200
    response.body.should == {:some => "result"}.to_json
  end

  it "passes spelling_suggestion to database and returns response in JSON" do
    Xapit.database.stub(:spelling_suggestion).with(:foo => "bar") { {:some => "result"} }
    response = @request.post("/xapit/spelling_suggestion", :params => {"foo" => "bar"}.to_json)
    response.status.should == 200
    response.body.should == {:some => "result"}.to_json
  end

  it "responds with 404 when unknown url" do
    response = @request.post("/xapit/foo")
    response.status.should == 404
  end
end
