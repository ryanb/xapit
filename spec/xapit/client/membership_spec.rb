require "spec_helper"

describe Xapit::Client::Membership do
  before(:each) do
    @member_class = Class.new
    @member = @member_class.new
    @member_class.send(:include, Xapit::Client::Membership)
  end

  it "does not define search class method when xapit isn't called" do
    @member_class.should_not respond_to(:search)
  end

  it "has a xapit method which makes an index builder" do
    @member_class.xapit { text :foo }
    @member_class.xapit_index_builder.text_attributes.keys.should == [:foo]
  end

  it "returns collection with query on search" do
    @member_class.xapit { text :foo }
    @member_class.search("hello").query.should == [{:include_classes => [@member_class]}, {:search => ["hello"]}]
  end
end
