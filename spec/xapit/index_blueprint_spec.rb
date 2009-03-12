require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::IndexBlueprint do
  before(:each) do
    @index = Xapit::IndexBlueprint.new(Object)
  end
  
  it "should remember text attributes" do
    @index.text(:foo)
    @index.text(:bar, :blah)
    @index.text_attributes.should == [:foo, :bar, :blah]
  end
  
  it "should fetch words from string, ignoring punctuation" do
    @index.stripped_words("Foo! bar.").should == %w[foo bar]
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
  
  it "should have a value for each facet" do
    member = Object.new
    stub(member).foo { "ABC" }
    stub(member).bar { 123 }
    @index.facet :foo
    @index.facet :bar
    @index.values(member).should == %w[ABC 123]
  end
  
  it "should add a field term for facets" do
    member = Object.new
    stub(member).foo { "ABC" }
    @index.facet(:foo)
    @index.field_terms(member).should == %w[Xfoo-abc]
  end
  
  it "should add terms and values to xapian document" do
    member = Object.new
    stub(member).id { 123 }
    stub(@index).values { %w[value list] }
    stub(@index).terms { %w[term list] }
    doc = @index.document_for(member)
    doc.should be_kind_of(Xapian::Document)
    doc.data.should == "Object-123"
    doc.values.map(&:value).sort.should == %w[value list].sort
    doc.terms.map(&:term).sort.should == %w[term list].sort
  end
  
  it "should index member document into database" do
    path = File.dirname(__FILE__) + '/../tmp/xapiandb'
    FileUtils.rm_rf(path) if File.exist? path
    db = Xapian::WritableDatabase.new(path, Xapian::DB_CREATE_OR_OVERWRITE)
    member = Object.new
    stub(member).id { 123 }
    stub(Object).each.yields(member)
    @index.index_into_database(db)
    db.doccount.should == 1
    db.flush
  end
  
  it "should remember all blueprints and index each of them" do
    db = Object.new
    stub(db).add_document
    mock(@index).index_into_database(db)
    Xapit::IndexBlueprint.index_all(db)
  end
  
  it "should pass in extra arguments to each method" do
    index = Xapit::IndexBlueprint.new(Object, :foo, :bar => :blah)
    mock(Object).each(:foo, :bar => :blah)
    index.index_into_database(nil)
  end
end
