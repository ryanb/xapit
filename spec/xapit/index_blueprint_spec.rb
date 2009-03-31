require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::IndexBlueprint do
  before(:each) do
    @index = Xapit::IndexBlueprint.new(XapitMember)
  end
  
  it "should remember text attributes" do
    @index.text(:foo)
    @index.text(:bar, :blah)
    @index.text_attributes.keys.should include(:foo, :bar, :blah)
  end
  
  it "should return terms for text attributes" do
    member = Object.new
    stub(member).description { "This is a test" }
    @index.text(:description)
    @index.text_terms(member).should == %w[this is a test]
  end
  
  it "should convert attribute to string when converting text to terms" do
    member = Object.new
    stub(member).num { 123 }
    @index.text(:num)
    @index.text_terms(member).should == %w[123]
  end
  
  it "should map field to term with 'X' prefix" do
    member = Object.new
    stub(member).category { "Water" }
    @index.field(:category)
    @index.field_terms(member).should == %w[Xcategory-water]
  end
  
  it "should have base terms with class name and id" do
    member = Object.new
    stub(member).id { 123 }
    @index.base_terms(member).should == %w[CObject QObject-123]
  end
  
  it "should add terms, values and options for facets" do
    stub(XapitMember).xapit_index_blueprint { @index }
    member = XapitMember.new(:foo => ["ABC", "DEF"])
    ids = Xapit::FacetBlueprint.new(XapitMember, 0, :foo).identifiers_for(member)
    @index.facet(:foo)
    @index.facet_terms(member).should == ids.map { |id| "F#{id}" }
    @index.values(member).should == { 0 => ids.join('-') }
    @index.save_facet_options_for(member)
    ids.map { |id| Xapit::FacetOption.find(id).name }.should == ["ABC", "DEF"]
  end
  
  it "should add terms and values to xapian document" do
    member = Object.new
    stub(member).id { 123 }
    stub(@index).values.returns(0 => 'value', 1 => 'list')
    stub(@index).terms { %w[term list] }
    doc = @index.document_for(member)
    doc.should be_kind_of(Xapian::Document)
    doc.data.should == "Object-123"
    doc.values.map(&:value).sort.should == %w[value list].sort
    doc.terms.map(&:term).sort.should == %w[term list].sort
  end
  
  it "should index member document into database" do
    Xapit::Config.setup(:database_path => File.dirname(__FILE__) + '/../tmp/xapdb')
    member = Object.new
    stub(member).id { 123 }
    stub(Object).each.yields(member)
    @index.index_all
    Xapit::Config.writable_database.doccount.should >= 1
    Xapit::Config.writable_database.flush
  end
  
  it "should remember all blueprints and index each of them" do
    Xapit::Config.setup(:database_path => File.dirname(__FILE__) + '/../tmp/xapian_db')
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
