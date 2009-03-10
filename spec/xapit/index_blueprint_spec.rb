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
    @index.terms(member).should == %w[this is a test]
  end
  
  it "should convert attribute to string when converting text to terms" do
    member = Object.new
    stub(member).num { 123 }
    @index.text(:num)
    @index.terms(member).should == %w[123]
  end
  
  it "should map field to term with proper prefix" do
    member = Object.new
    stub(member).category { "Water" }
    @index.field(:category)
    @index.terms(member).should == %w[Xcategory-water]
  end
end
