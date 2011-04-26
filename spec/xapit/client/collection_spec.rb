require "spec_helper"

describe Xapit::Client::Collection do
  it "builds up query with in_classes, search, where, order calls" do
    collection1 = Xapit::Client::Collection.new([:initial])
    collection2 = collection1.in_classes(String).search("hello").where(:foo => "bar").order(1, 2, 3)
    collection1.query.should == [:initial]
    collection2.query.should == [:initial, {:in_classes => [String]}, {:search => "hello"}, {:where => {:foo => "bar"}}, {:order => [1, 2, 3]}]
  end

  it "returns indexed records and delegates array methods to it" do
    load_xapit_database
    member = XapitMember.new
    member.xapit_index
    collection = Xapit::Client::Collection.new([{:search => ""}])
    collection.records.should == [member]
    collection.should respond_to(:flatten)
    collection.flatten.should == [member]
  end
end
