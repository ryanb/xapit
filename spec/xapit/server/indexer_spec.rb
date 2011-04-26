require "spec_helper"

describe Xapit::Server::Indexer do
  it "generates a xapian document with text data" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "hello world", :text => {}}, :name => {:value => "John", :text => {}}})
    document = indexer.document
    document.should be_kind_of(Xapian::Document)
    document.terms.map(&:term).should include(*%w[hello world John])
  end

  it "generates a xapian document with text weight data" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "hello", :text => {:weight => 3}}})
    indexer.document.terms.map(&:wdf).should include(3)
  end

  it "adds the id and class to xapian document data" do
    indexer = Xapit::Server::Indexer.new(:class => "Foo", :id => "123")
    document = indexer.document
    document.should be_kind_of(Xapian::Document)
    document.data.should == "Foo-123"
  end

  it "includes class/id in terms list" do
    indexer = Xapit::Server::Indexer.new(:class => "Foo", :id => "123")
    indexer.terms.should include("CFoo", "QFoo-123")
  end

  it "includes fields in terms list" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "Hello", :field => {}}})
    indexer.terms.should include("Xgreeting-hello")
  end

  it "includes test attributes in weighted terms list" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "hello world", :text => {}}})
    indexer.weighted_terms.should include(["hello", 1], ["world", 1])
  end
end
