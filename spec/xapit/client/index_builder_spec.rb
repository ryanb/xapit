require "spec_helper"

describe Xapit::Client::IndexBuilder do
  it "stores text attributes" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text(:foo)
    builder.text(:bar, :blah)
    builder.text_attributes.should == [:foo, :bar, :blah]
  end
end
