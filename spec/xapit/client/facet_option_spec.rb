require "spec_helper"

describe Xapit::Client::FacetOption do
  it "has an identifier using attribute and value" do
    option = Xapit::Client::FacetOption.new("greeting", :value => "Hello")
    option.identifier.should eq(Xapit.facet_identifier("greeting", "Hello"))
  end

  it "has a name and count matching passed options" do
    option = Xapit::Client::FacetOption.new("greeting", :value => "Hello", :count => "3")
    option.name.should eq("Hello")
    option.count.should eq(3)
  end
end
