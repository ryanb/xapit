require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::FacetOption do
  it "should generate unique identifier based on name" do
    foo1 = Xapit::FacetOption.new
    foo1.name = "foo"
    
    foo2 = Xapit::FacetOption.new
    foo2.name = "foo"
    
    bar = Xapit::FacetOption.new
    bar.name = "bar"
    
    foo1.identifier.should == foo2.identifier
    foo1.identifier.should_not == bar.identifier
    foo1.identifier.length.should == 7
  end
end
