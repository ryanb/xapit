require "spec_helper"

describe Xapit::Client::IndexBuilder do
  it "stores text attributes with option" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :foo, :weight => 3
    builder.text :bar, :blah
    builder.attributes[:foo].should == {:text => {:weight => 3}}
    builder.attributes[:bar].should == {:text => {}}
    builder.attributes[:blah].should == {:text => {}}
  end

  it "stores field attribute with option" do
    builder = Xapit::Client::IndexBuilder.new
    builder.field :foo, :weight => 3
    builder.field :bar, :blah
    builder.attributes[:foo].should == {:field => {:weight => 3}}
    builder.attributes[:bar].should == {:field => {}}
    builder.attributes[:blah].should == {:field => {}}
  end

  it "stores sortable attribute with option" do
    builder = Xapit::Client::IndexBuilder.new
    builder.sortable :foo, :weight => 3
    builder.sortable :bar, :blah
    builder.attributes[:foo].should == {:sortable => {:weight => 3}}
    builder.attributes[:bar].should == {:sortable => {}}
    builder.attributes[:blah].should == {:sortable => {}}
  end

  it "stores facet attribute with options" do
    builder = Xapit::Client::IndexBuilder.new
    builder.facet :foo
    builder.facet :bar, "Zap"
    builder.attributes[:foo].should == {:facet => {}}
    builder.attributes[:bar].should == {:facet => {:name => "Zap"}}
  end

  it "merges member values with attributes for index data" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :greeting, :weight => 3
    builder.field :name
    member = XapitMember.new(:greeting => "hello world", :name => "John")
    data = builder.index_data(member)
    data[:id].should == member.id
    data[:class].should == "XapitMember"
    data[:attributes].should == {:greeting => {:value => "hello world", :text => {:weight => 3}}, :name => {:value => "John", :field => {}}}
  end

  it "indexes an object by adding it to the current database" do
    load_xapit_database
    Xapit.database.xapian_database.doccount.should == 0
    builder = Xapit::Client::IndexBuilder.new
    member = XapitMember.new(:greeting => "Hello world")
    builder.index(member)
    Xapit.database.xapian_database.doccount.should == 1
  end
end
