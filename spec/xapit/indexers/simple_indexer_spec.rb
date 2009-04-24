require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::SimpleIndexer do
  before(:each) do
    @index = Xapit::IndexBlueprint.new(XapitMember)
    @indexer = Xapit::SimpleIndexer.new(@index)
  end
  
  it "should return terms for text attributes" do
    member = Object.new
    stub(member).description { "This is a test" }
    @index.text(:description)
    @indexer.text_terms(member).should == %w[this is a test]
  end
  
  it "should return text term with stemming added" do
    member = Object.new
    stub(member).description { "jumping high" }
    @index.text(:description)
    @indexer.text_terms_with_stemming(member).should == %w[jumping Zjump high Zhigh]
  end
  
  it "should convert attribute to string when converting text to terms" do
    member = Object.new
    stub(member).num { 123 }
    @index.text(:num)
    @indexer.text_terms(member).should == %w[123]
  end
  
  it "should add text terms to document when indexing attributes" do
    stub(@indexer).text_terms_with_stemming { %w[term list] }
    document = Xapian::Document.new
    @indexer.index_text_attributes(nil, document)
    document.terms.map(&:term).sort.should == %w[term list].sort
  end
  
  it "should use given block to generate text terms" do
    member = Object.new
    stub(member).name { "foobar" }
    @index.text(:name) { |t| [t.length] }
    @indexer.text_terms(member).should == ["6"]
  end
end
