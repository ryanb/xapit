require "spec_helper"

describe Xapit::Client::Membership do
  before(:each) do
    @member_class = Class.new
    @member_class.send(:include, Xapit::Client::Membership)
  end

  it "does not define search class method when xapit isn't called" do
    @member_class.should_not respond_to(:search)
  end

  it "has a xapit method which makes an index builder" do
    @member_class.xapit { text :foo }
    @member_class.xapit_index_builder.attributes.keys.should eq([:foo])
  end

  it "returns collection with query on search" do
    @member_class.xapit { text :foo }
    @member_class.search("hello").clauses.should eq([{:in_classes => [@member_class]}, {:search => "hello"}])
  end

  it "returns collection with no search query" do
    @member_class.xapit { text :foo }
    @member_class.search.clauses.should eq([{:in_classes => [@member_class]}])
    @member_class.search("").clauses.should eq([{:in_classes => [@member_class]}])
  end

  it "includes facets" do
    @member_class.xapit { facet :foo }
    @member_class.search.clauses.should eq([{:in_classes => [@member_class]}, {:include_facets => [:foo]}])
  end

  it "has a model_adapter" do
    @member_class.xapit_model_adapter.should be_kind_of(Xapit::Client::DefaultModelAdapter)
  end
end
