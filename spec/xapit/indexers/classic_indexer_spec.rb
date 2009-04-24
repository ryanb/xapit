require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::ClassicIndexer do
  before(:each) do
    @index = Xapit::IndexBlueprint.new(XapitMember)
    @indexer = Xapit::ClassicIndexer.new(@index)
  end
  
  it "should add text terms to document when indexing attributes" do
    member = Object.new
    stub(member).name { "jumping high" }
    @index.text(:name)
    document = Xapian::Document.new
    @indexer.index_text_attributes(member, document)
    document.terms.map(&:term).sort.should == %w[Zjump Zhigh jumping high].sort
  end
  
  it "should use given block to generate text terms" do
    member = Object.new
    stub(member).name { "foobar" }
    @index.text(:name) { |t| [t.length] }
    document = Xapian::Document.new
    @indexer.index_text_attributes(member, document)
    document.terms.map(&:term).sort.should == %w[6].sort
  end
end
