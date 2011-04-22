__END__
require "spec_helper"

describe Xapit::ClassicIndexer do
  before(:each) do
    @index = Xapit::IndexBlueprint.new(XapitMember)
    @indexer = Xapit::ClassicIndexer.new(@index)
  end

  it "should add text terms to document when indexing attributes" do
    pending "not sure yet why this is failing"
    member = Object.new
    stub(member).name { "jumping high" }
    @index.text(:name)
    document = Xapit::Document.new
    @indexer.index_text_attributes(member, document)
    document.terms.sort.should == %w[Zjump Zhigh jumping high].sort
  end

  it "should use given block to generate text terms" do
    member = Object.new
    stub(member).name { "foobar" }
    @index.text(:name) { |t| [t.length] }
    document = Xapit::Document.new
    @indexer.index_text_attributes(member, document)
    document.terms.sort.should == %w[6].sort
  end

  it "should return terms separated by array" do
    member = Object.new
    stub(member).description { ["foo bar", 6, "", nil] }
    @index.text(:description)
    document = Xapit::Document.new
    @indexer.index_text_attributes(member, document)
    document.terms.sort.should == ["foo bar", "6"].sort
  end
end
