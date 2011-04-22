require "spec_helper"

describe Xapit::Client::Collection do
  it "builds up query with include_classes, search, where, order calls" do
    collection1 = Xapit::Client::Collection.new([:initial])
    collection2 = collection1.include_classes(String).search(1).where(2).order(3)
    collection1.query.should == [:initial]
    collection2.query.should == [:initial, {:include_classes => [String]}, {:search => [1]}, {:where => [2]}, {:order => [3]}]
  end
end
