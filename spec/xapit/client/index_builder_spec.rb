require "spec_helper"

describe Xapit::Client::IndexBuilder do
  it "stores text attributes with option" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :foo, :weight => 3
    builder.text :bar, :blah
    builder.attributes[:foo].should eq(:text => {:weight => 3})
    builder.attributes[:bar].should eq(:text => {})
    builder.attributes[:blah].should eq(:text => {})
  end

  it "stores field attribute with option" do
    builder = Xapit::Client::IndexBuilder.new
    builder.field :foo, :weight => 3
    builder.field :bar, :blah
    builder.attributes[:foo].should eq(:field => {:weight => 3})
    builder.attributes[:bar].should eq(:field => {})
    builder.attributes[:blah].should eq(:field => {})
  end

  it "stores sortable attribute with option" do
    builder = Xapit::Client::IndexBuilder.new
    builder.sortable :foo, :weight => 3
    builder.sortable :bar, :blah
    builder.attributes[:foo].should eq(:sortable => {:weight => 3})
    builder.attributes[:bar].should eq(:sortable => {})
    builder.attributes[:blah].should eq(:sortable => {})
  end

  it "stores facet attribute with options" do
    builder = Xapit::Client::IndexBuilder.new
    builder.facet :foo
    builder.facet :bar, "Zap"
    builder.attributes[:foo].should eq(:facet => {})
    builder.attributes[:bar].should eq(:facet => {:name => "Zap"})
  end

  it "fetches facets back" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :test
    builder.facet :foo
    builder.facet :bar
    builder.facets.should eq([:foo, :bar])
  end

  it "merges member values with attributes for index data" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :greeting, :weight => 3
    builder.field :name
    member = XapitMember.new(:greeting => "hello world", :name => "John")
    data = builder.document_data(member)
    data[:id].should eq(member.id)
    data[:class].should eq("XapitMember")
    data[:attributes].should eq(:greeting => {:value => "hello world", :text => {:weight => 3}}, :name => {:value => "John", :field => {}})
  end

  it "uses block when given" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text(:greeting) { |greet| greet.reverse }
    member = XapitMember.new(:greeting => "hello")
    data = builder.document_data(member)
    data[:attributes].should eq(:greeting => {:value => "olleh", :text => {}})
    builder.attributes[:greeting][:_block].should_not be_nil
  end

  it "indexes an object by adding it to the current database" do
    load_xapit_database
    Xapit.database.xapian_database.doccount.should eq(0)
    builder = Xapit::Client::IndexBuilder.new
    member = XapitMember.new(:greeting => "Hello world")
    builder.add_document(member)
    Xapit.database.xapian_database.doccount.should eq(1)
  end
end
