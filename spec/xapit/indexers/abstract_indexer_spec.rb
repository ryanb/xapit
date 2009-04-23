require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::AbstractIndexer do
  before(:each) do
    Xapit::Config.setup(:database_path => File.dirname(__FILE__) + '/../../tmp/xapiandb')
    @index = Xapit::IndexBlueprint.new(XapitMember)
    @indexer = Xapit::SimpleIndexer.new(@index)
  end
  
  it "should return terms for text attributes" do
    member = Object.new
    stub(member).description { "This is a test" }
    @index.text(:description)
    @indexer.text_terms(member).should == %w[this is a test]
  end
  
  it "should convert attribute to string when converting text to terms" do
    member = Object.new
    stub(member).num { 123 }
    @index.text(:num)
    @indexer.text_terms(member).should == %w[123]
  end
  
  it "should map field to term with 'X' prefix" do
    member = Object.new
    stub(member).category { "Water" }
    @index.field(:category)
    @indexer.field_terms(member).should == %w[Xcategory-water]
  end
  
  it "should add terms separately when array is returned" do
    member = Object.new
    stub(member).category { ["Water", "Liquid"] }
    @index.field(:category)
    @indexer.field_terms(member).should == %w[Xcategory-water Xcategory-liquid]
  end
  
  it "should have base terms with class name and id" do
    member = Object.new
    stub(member).id { 123 }
    @indexer.base_terms(member).should == %w[CObject QObject-123]
  end
  
  it "should add terms, values and options for facets" do
    stub(XapitMember).xapit_index_blueprint { @index }
    member = XapitMember.new(:foo => ["ABC", "DEF"])
    ids = Xapit::FacetBlueprint.new(XapitMember, 0, :foo).identifiers_for(member)
    @index.facet(:foo)
    @indexer.facet_terms(member).should == ids.map { |id| "F#{id}" }
    @indexer.values(member).should == [ids.join('-')]
    @indexer.save_facet_options_for(member)
    ids.map { |id| Xapit::FacetOption.find(id).name }.should == ["ABC", "DEF"]
  end
  
  it "should add values for sortable fields" do
    member = Object.new
    stub(member).name { "Foo" }
    @index.sortable(:name)
    @indexer.values(member).should == ["foo"]
  end
  
  it "should add terms and values to xapian document" do
    member = Object.new
    stub(member).id { 123 }
    stub(@indexer).values.returns(%w[value list])
    stub(@indexer).terms { %w[term list] }
    doc = @indexer.document_for(member)
    doc.should be_kind_of(Xapian::Document)
    doc.data.should == "Object-123"
    doc.values.map(&:value).sort.should == %w[value list].sort
    doc.terms.map(&:term).sort.should == %w[term list].sort
  end
end
