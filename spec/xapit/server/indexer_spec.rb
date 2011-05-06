require "spec_helper"

describe Xapit::Server::Indexer do
  it "generates a xapian document with terms and values" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "hello world", :text => {}}, :name => {:value => "John", :field => {}}})
    document = indexer.document
    document.should be_kind_of(Xapian::Document)
    document.terms.map(&:term).should include(*%w[hello world])
    document.values.map(&:value).should == [Xapit.serialize_value("John")]
  end

  it "generates a xapian document with text weight data" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "hello", :text => {:weight => 3}}})
    indexer.document.terms.map(&:wdf).should include(3)
  end

  it "stores sortable attributes as serialized values" do
    time = Time.now
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => time, :sortable => {}}})
    document = indexer.document
    document.values.map(&:value).should == [Xapit.serialize_value(time)]
  end

  it "adds the id and class to xapian document data" do
    indexer = Xapit::Server::Indexer.new(:class => "Foo", :id => "123")
    document = indexer.document
    document.should be_kind_of(Xapian::Document)
    document.data.should == "Foo-123"
  end

  it "includes class/id in terms list" do
    indexer = Xapit::Server::Indexer.new(:class => "Foo", :id => "123")
    indexer.terms.should include(["CFoo", 1], ["QFoo-123", 1])
  end

  it "includes fields in terms list" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "Hello", :field => {}}})
    indexer.terms.should include(["Xgreeting-hello", 1])
  end

  it "indexes array values separately" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => ["Hello", "world"], :field => {}}})
    indexer.terms.should include(["Xgreeting-hello", 1], ["Xgreeting-world", 1])
  end

  it "includes text attributes in terms list" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "hello world", :text => {}}})
    indexer.terms.should include(["hello", 1], ["world", 1])
  end

  it "handles odd text attributes correctly" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => [6, nil, ""], :text => {}}})
    indexer.terms.should include(["6", 1])
    indexer.terms.should_not include(["", 1])
    indexer.terms.should_not include([nil, 1])
  end

  it "handles odd field attributes correctly" do
    # TODO add date handling
    time = Time.now
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => [6, nil, time], :field => {}}})
    indexer.terms.should include(["Xgreeting-6", 1], ["Xgreeting-", 1], ["Xgreeting-#{time.to_i}", 1])
  end

  it "includes field and sortable values" do
    indexer = Xapit::Server::Indexer.new(:attributes => {:greeting => {:value => "Hello", :field => {}, :sortable => {}}})
    indexer.values[Xapit.value_index(:field, "greeting")].should == Xapit.serialize_value("Hello")
    indexer.values[Xapit.value_index(:sortable, "greeting")].should == Xapit.serialize_value("Hello")
  end
end
