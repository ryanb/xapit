require "spec_helper"

describe Xapit::App do
  before(:each) do
    @app = Xapit::App.new
    @request = Rack::MockRequest.new(@app)
  end

  it "adds new document to the database" do
    response = @request.post("/xapit/documents", :params => {:document => {:data => "String-123"}.to_json})
    response.status.should == 200
    Xapit::Config.database.doccount.should == 1
  end

  it "responds with 404 when unknown url" do
    response = @request.post("/xapit/foo")
    response.status.should == 404
  end

  describe "indexed" do
    before(:each) do
      XapitMember.xapit do |index|
        index.text :name
      end
      @hello = XapitMember.new(:name => "hello world")
      Xapit.index_all
    end

    it "removes document from the database" do
      Xapit::Config.database.doccount.should == 1
      response = @request.delete("/xapit/documents", :params => {:document => {:data => "XapitMember-#{@hello.id}"}.to_json})
      response.status.should == 200
      Xapit::Config.database.doccount.should == 0
    end

    it "updates documents in the database" do
      XapitMember.search("hello").should == [@hello]
      response = @request.put("/xapit/documents", :params => {:document => {:data => "XapitMember-#{@hello.id}", :terms => "goodbye"}.to_json})
      response.status.should == 200
      XapitMember.search("hello").should == []
    end
  end
end
