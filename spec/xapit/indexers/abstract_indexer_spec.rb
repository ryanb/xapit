require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::AbstractIndexer do
  before(:each) do
    XapitMember.xapit { } # to ensure methods are included
    @index = Xapit::IndexBlueprint.new(XapitMember)
    @indexer = Xapit::SimpleIndexer.new(@index)
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
    Xapit::Config.database.writable_database # force xapit to use a writable database at the beginning
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
    stub(@indexer).other_terms { %w[term list] }
    doc = @indexer.document_for(member)
    doc.should be_kind_of(Xapian::Document)
    doc.data.should == "Object-123"
    doc.values.map(&:value).sort.should == %w[value list].sort
    doc.terms.map(&:term).sort.should == %w[term list].sort
  end
  
  it "should convert time to integer before saving as field term" do
    member = Object.new
    stub(member).created_at { Time.now }
    @index.field(:created_at)
    @indexer.field_terms(member).should == ["Xcreated_at-#{member.created_at.to_i}"]
  end
  
  it "should convert date to time then integer before saving as field term" do
    member = Object.new
    stub(member).created_on { Date.today }
    @index.field(:created_on)
    @indexer.field_terms(member).should == ["Xcreated_on-#{member.created_on.to_time.to_i}"]
  end
  
  it "should use sortable_serialze for numeric sortable" do
    member = Object.new
    stub(member).age { 7.89 }
    @index.sortable(:age)
    @indexer.values(member).should == [Xapian.sortable_serialise(7.89)]
  end
  
  it "should only use first value if sortable attribute is an array" do
    member = Object.new
    stub(member).age { [1, 2] }
    @index.sortable(:age)
    @indexer.values(member).should == [Xapian.sortable_serialise(1)]
  end
  
  it "should add sortable_serialze value for numeric field" do
    member = Object.new
    stub(member).age { [1, 2] }
    @index.field(:age)
    @indexer.values(member).should == [Xapian.sortable_serialise(1)]
  end
  
  it "should use sortable_serialze for date field" do
    date = Date.today
    member = Object.new
    stub(member).age { date }
    @index.field(:age)
    @indexer.values(member).should == [Xapian.sortable_serialise(date.to_time.to_i)]
  end
  
  it "should use sortable_serialze for time field" do
    time = Time.now
    member = Object.new
    stub(member).age { time }
    @index.field(:age)
    @indexer.values(member).should == [Xapian.sortable_serialise(time.to_i)]
  end
end
