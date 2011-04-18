require "spec_helper"

describe Xapit::Client::Collection do
  it "remembers member class and defaults query to an empty array" do
    collection = Xapit::Client::Collection.new(String)
    collection.member_class.should == String
    collection.query.should == []
  end

  it "builds up query with search, where, and order calls" do
    collection1 = Xapit::Client::Collection.new(String, [:initial])
    collection2 = collection1.search(1).where(2).order(3)
    collection1.query.should == [:initial]
    collection2.query.should == [:initial, {:type => :search, :args => [1]}, {:type => :where, :args => [2]}, {:type => :order, :args => [3]}]
  end
end
