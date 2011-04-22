require "spec_helper"

describe Xapit::Server::Indexer do
  it "generates a xapian document with text terms" do
    indexer = Xapit::Server::Indexer.new(:text => "foo bar")
    document = indexer.document
    document.should be_kind_of(Xapian::Document)
    document.terms.map(&:term).sort.should == %w[foo bar].sort
  end

  it "adds the id and class to xapian document data" do
    indexer = Xapit::Server::Indexer.new(:id => "123", :class => "Foo")
    document = indexer.document
    document.should be_kind_of(Xapian::Document)
    document.data.should == "Foo-123"
  end
end
