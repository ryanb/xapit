require "spec_helper"

describe Xapit::Client::Collection do
  it "builds up query with in_classes, search, where, order calls" do
    collection1 = Xapit::Client::Collection.new([:initial])
    collection2 = collection1.in_classes(0).search(1).where(2).order(3)
    collection1.query.should == [:initial]
    collection2.query.should == [:initial, {:in_classes => [0]}, {:search => [1]}, {:where => [2]}, {:order => [3]}]
  end

  it "returns results for indexed records" do
    load_xapit_database
    member = XapitMember.new
    member.xapit_index
    collection = Xapit::Client::Collection.new([])
    collection.results.should == [member]
  end
end
