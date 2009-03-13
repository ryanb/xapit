require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::FacetBlueprint do
  it "should generate unique identifier based on attribute and value" do
    facet1 = Xapit::FacetBlueprint.new(0, :to_s)
    facet2 = Xapit::FacetBlueprint.new(0, :length)
    facet1.identifier_for("foo").length.should == 7
    facet1.identifier_for("foo").should_not == facet1.identifier_for("bar")
    facet1.identifier_for("foo").should_not == facet2.identifier_for("foo")
  end
end
