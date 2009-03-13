require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::FacetOption do
  it "should combine previous identifiers with current one on to_param" do
    option = Xapit::FacetOption.new(nil, nil, ["abc", "123"])
    stub(option).identifier { "foo" }
    option.to_param.should == "abc-123-foo"
  end
end
