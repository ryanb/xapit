require "spec_helper"

describe Xapit::FacetBlueprint do
  it "should generate unique identifier based on attribute and value" do
    facet1 = Xapit::FacetBlueprint.new(XapitMember, 0, :to_s)
    facet2 = Xapit::FacetBlueprint.new(XapitMember, 0, :length)
    facet1.identifiers_for("foo").first.length.should == 7
    facet1.identifiers_for("foo").should_not == facet1.identifiers_for("bar")
    facet1.identifiers_for("foo").should_not == facet2.identifiers_for("foo")
  end

  it "should generate unique identifiers for each value returned" do
    facet = Xapit::FacetBlueprint.new(XapitMember, 0, :to_a)
    facet.identifiers_for(["foo", "bar"]).size.should == 2
  end

  it "should humanize attribute for name if one isn't given" do
    Xapit::FacetBlueprint.new(XapitMember, 0, :visible).name.should == "Visible"
  end

  it "should use custom name if given" do
    Xapit::FacetBlueprint.new(XapitMember, 0, :visible, "custom").name.should == "custom"
  end

  it "should not have identifiers for blank values" do
    facet = Xapit::FacetBlueprint.new(XapitMember, 0, :to_a)
    facet.identifiers_for(["", nil, "bar"]).size.should == 1
  end
end
