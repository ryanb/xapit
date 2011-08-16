require "spec_helper"

describe Xapit::Client::Facet do
  it "sets the name to capitalized attribute" do
    facet = Xapit::Client::Facet.new("building_type", [])
    facet.name.should eq("Building Type")
  end

  it "sets the name as symbol to capitalized attribute" do
    facet = Xapit::Client::Facet.new(:building_type, [])
    facet.name.should eq("Building Type")
  end
end
