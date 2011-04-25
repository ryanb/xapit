require "spec_helper"

describe Xapit::Client::Collection do
  it "builds up query with search_classes, search, where, order calls" do
    collection1 = Xapit::Client::Collection.new([:initial])
    collection2 = collection1.search_classes(0).search(1).where(2).order(3)
    collection1.query.should == [:initial]
    collection2.query.should == [:initial, {:search_classes => [0]}, {:search => [1]}, {:where => [2]}, {:order => [3]}]
  end

  it "returns results which match the indexed records" do
    load_xapit_database
    # TODO
  end
end
