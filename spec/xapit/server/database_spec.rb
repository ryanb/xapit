require "spec_helper"

describe Xapit::Server::Database do
  before(:each) do
    load_xapit_database
    @database = Xapit.database
  end

  it "has a xapian database" do
    @database.xapian_database.should be_kind_of(Xapian::WritableDatabase)
  end

  it "adds a document to the database" do
    @database.xapian_database.doccount.should eq(0)
    @database.add_document(:attributes => {:greeting => {:value => "hello world", :text => {}}})
    @database.xapian_database.doccount.should eq(1)
  end

  it "queries the database for results" do
    @database.add_document(:attributes => {:greeting => {:value => "hello world", :text => {}}}, :id => 123, :class => "Greeting")
    @database.query([{:search => "hello"}])[:records].first[:id].should == "123"
  end

  it "removes a document from the database" do
    @database.xapian_database.doccount.should eq(0)
    @database.add_document(:id => 123, :class => "Greeting")
    @database.xapian_database.doccount.should eq(1)
    @database.remove_document(:id => 123, :class => "Greeting")
    @database.xapian_database.doccount.should eq(0)
  end

  it "updates a document in the database" do
    @database.add_document(:attributes => {:greeting => {:value => "hello world", :text => {}}}, :id => 123, :class => "Greeting")
    @database.update_document(:attributes => {:greeting => {:value => "aloha", :text => {}}}, :id => 123, :class => "Greeting")
    @database.query([{:search => "aloha"}])[:records].first[:id].should == "123"
  end

  it "reopens the database" do
    @database.xapian_database.should_receive(:reopen)
    @database.reopen
  end
end
