require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Xapit::IndexBlueprint do
  before(:each) do
    @index = Xapit::IndexBlueprint.new(XapitMember)
  end
  
  it "should remember text attributes" do
    @index.text(:foo)
    @index.text(:bar, :blah)
    @index.text(:custom) { |t| t*t }
    @index.text_attributes.keys.should include(:foo, :bar, :blah, :custom)
    @index.text_attributes[:foo][:proc].should be_nil
    @index.text_attributes[:custom][:proc].should be_kind_of(Proc)
  end
  
  it "should remember field attributes" do
    @index.field(:foo)
    @index.field(:bar, :blah)
    @index.field_attributes.should include(:foo, :bar, :blah)
  end
  
  it "should remember facets" do
    @index.facet(:foo)
    @index.facet(:bar, "Baz")
    @index.facets.map(&:name).should == ["Foo", "Baz"]
  end
  
  it "should remember sortable attributes" do
    @index.sortable(:foo)
    @index.sortable(:bar, :blah)
    @index.sortable_attributes.should include(:foo, :bar, :blah)
  end
  
  it "should have a sortable position offset by facets" do
    @index.facet(:foo)
    @index.facet(:test)
    @index.sortable(:bar, :blah)
    @index.sortable_position_for(:blah).should == 3
  end
  
  it "should index member document into database" do
    XapitMember.new
    @index.index_all
    Xapit::Config.writable_database.doccount.should >= 1
    Xapit::Config.writable_database.flush
  end
  
  it "should remember all blueprints and index each of them" do
    stub(Xapit::Config.writable_database).add_document
    mock(@index).index_all
    Xapit::IndexBlueprint.index_all
  end
  
  it "should pass in extra arguments to each method" do
    index = Xapit::IndexBlueprint.new(Object, :foo, :bar => :blah)
    mock(Object).find_each(:foo, :bar => :blah)
    index.index_all
  end
end
