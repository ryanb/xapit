require "spec_helper"

describe Xapit::Server::Indexer do
  it "generates a xapian document with text data" do
    indexer = Xapit::Server::Indexer.new(:texts => {:greeting => {:value => "hello world"}, :name => {:value => "John"}})
    document = indexer.document
    document.should be_kind_of(Xapian::Document)
    document.terms.map(&:term).sort.should == %w[hello world John].sort
  end

  it "generates a xapian document with text weight data" do
    indexer = Xapit::Server::Indexer.new(:texts => {:greeting => {:value => "hello", :weight => 3}})
    indexer.document.terms.first.wdf.should == 3
  end

  it "adds the id and class to xapian document data" do
    indexer = Xapit::Server::Indexer.new(:id => "123", :class => "Foo")
    document = indexer.document
    document.should be_kind_of(Xapian::Document)
    document.data.should == "Foo-123"
  end
end
