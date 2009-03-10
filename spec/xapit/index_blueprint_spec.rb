require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::IndexBlueprint do
  before(:each) do
    @index = Xapit::IndexBlueprint.new
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
end
