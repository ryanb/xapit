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

  it "combines previous identifiers with current one on to_param" do
    id = Xapit.facet_identifier("greeting", "Hello")
    option = Xapit::Client::FacetOption.new("greeting", {:value => "Hello"}, %w[abc 123])
    option.to_param.should == "abc-123-#{id}"
  end

  it "removes current identifier from previous identifiers if it exists" do
    id = Xapit.facet_identifier("greeting", "Hello")
    option = Xapit::Client::FacetOption.new("greeting", {:value => "Hello"}, %w[abc 123] + [id])
    option.to_param.should == "abc-123"
  end
end
