require "spec_helper"

describe Xapit::Server::Database do
  before(:each) do
    @database = blank_xapit_database
  end

  it "has a xapian database" do
    @database.xapian_database.should be_kind_of(Xapian::WritableDatabase)
  end

  it "adds a document to the database" do
    @database.xapian_database.doccount.should == 0
    @database.add_document(:texts => {:greeting => {:value => "hello world"}})
    @database.xapian_database.doccount.should == 1
  end
end
