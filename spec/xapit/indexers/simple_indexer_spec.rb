require "spec_helper"

describe Xapit::SimpleIndexer do
  before(:each) do
    @index = Xapit::IndexBlueprint.new(XapitMember)
    @indexer = Xapit::SimpleIndexer.new(@index)
  end
  
  it "should return terms for text attributes" do
    member = Object.new
    stub(member).description { "This is a test" }
    @index.text(:description)
    @indexer.terms_for_attribute(member, :description, {}).should == %w[this is a test]
  end
  
  it "should return text terms with stemming added" do
    member = Object.new
    stub(member).description { "jumping high" }
    @index.text(:description)
    @indexer.stemmed_terms_for_attribute(member, :description, {}).should == %w[Zjump Zhigh]
  end
  
  it "should convert attribute to string when converting text to terms" do
    member = Object.new
    stub(member).num { 123 }
    @index.text(:num)
    @indexer.terms_for_attribute(member, :num, {}).should == %w[123]
  end
  
  it "should add text terms to document when indexing attributes" do
    @index.text(:description)
    stub(@indexer).terms_for_attribute { %w[term list] }
    document = Xapit::Document.new
    @indexer.index_text_attributes(nil, document)
    document.terms.sort.should == %w[Zlist Zterm list term].sort
  end
  
  it "should use given block to generate text terms" do
    member = Object.new
    stub(member).name { "foobar" }
    proc = lambda { |t| [t.length] }
    @indexer.terms_for_attribute(member, :name, { :proc => proc }).should == ["6"]
  end
  
  it "should increment term frequency by weight option" do
    member = Object.new
    stub(member).description { "This is a test" }
    @index.text(:description, :weight => 10)
    document = Xapit::Document.new
    @indexer.index_text_attributes(member, document)
    document.term_weights.first.should == 10
  end
  
  it "should return terms separated by array" do
    member = Object.new
    stub(member).description { ["foo bar", 6, "", nil] }
    @index.text(:description)
    @indexer.terms_for_attribute(member, :description, {}).should == ["foo bar", "6"]
  end
end
