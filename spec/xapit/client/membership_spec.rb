require "spec_helper"

describe Xapit::Client::Membership do
  before(:each) do
    @member_class = Class.new
    @member = @member_class.new
    @member_class.send(:include, Xapit::Client::Membership)
  end

  it "has a xapit method which makes an index builder" do
    @member_class.xapit do
      text :foo
    end
    @member_class.xapit_index_builder.should be_kind_of(Xapit::Client::IndexBuilder)
  end
end
