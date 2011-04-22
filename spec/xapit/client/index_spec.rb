require "spec_helper"

describe Xapit::Client::Index do
  it "parses text attributes into array of words" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :reverse
    index = Xapit::Client::Index.new(builder, "hello world")
    index.data[:text].should == ["dlrow", "olleh"]
  end
end
