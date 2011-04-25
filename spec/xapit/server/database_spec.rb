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
    @database.xapian_database.doccount.should == 0
    @database.add_document(:attributes => {:greeting => {:value => "hello world", :text => {}}})
    @database.xapian_database.doccount.should == 1
  end

  it "queries the database for results" do
    @database.add_document(:attributes => {:greeting => {:value => "hello world", :text => {}}}, :id => 123, :class => "Greeting")
    @database.query([{:search => ["hello"]}]).should == [{:class => "Greeting", :id => "123", :relevance => 100}]
  end
end
