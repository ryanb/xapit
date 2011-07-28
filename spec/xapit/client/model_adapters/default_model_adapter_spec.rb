require "spec_helper"

describe Xapit::Client::DefaultModelAdapter do
  it "should be default for generic classes" do
    Xapit::Client::DefaultModelAdapter.adapter_class(Object).should == Xapit::Client::DefaultModelAdapter
  end
end
