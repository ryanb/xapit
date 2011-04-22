require "spec_helper"

describe Xapit::Client::IndexBuilder do
  it "stores text attributes with weight" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text(:foo, :weight => 3)
    builder.text(:bar, :blah)
    builder.text_attributes.keys.should == [:foo, :bar, :blah]
    builder.text_attributes[:foo].should == {:weight => 3}
    builder.text_attributes[:bar].should == {}
  end
end
