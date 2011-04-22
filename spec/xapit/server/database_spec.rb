require "spec_helper"

describe Xapit::Server::Database do
  before(:each) do
    path = File.expand_path('../../../../tmp/testdb', __FILE__)
    template = File.expand_path('../../../fixtures/blankdb', __FILE__)
    FileUtils.rm_rf(path)
    @database = Xapit::Server::Database.new(path, template)
  end

  it "has a xapian database" do
    @database.xapian_database.should be_kind_of(Xapian::WritableDatabase)
  end

  it "adds a document to the database" do
    @database.xapian_database.doccount.should == 0
    @database.add_document(:text => "foo bar")
    @database.xapian_database.doccount.should == 1
  end
end
