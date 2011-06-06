require "spec_helper"

describe Xapit::Client::Collection do
  it "builds up clauses with in_classes, search, where, order calls" do
    collection1 = Xapit::Client::Collection.new([:initial])
    collection2 = collection1.in_classes(String).search("hello").where(:foo => "bar").order(:bar)
    collection1.clauses.should == [:initial]
    collection2.clauses.should == [:initial, {:in_classes => [String]}, {:search => "hello"}, {:where => {:foo => "bar"}}, {:order => [:bar, :asc]}]
  end

  it "returns same collection when searching nil or empty string" do
    collection1 = Xapit::Client::Collection.new
    collection1.search("").should == collection1
    collection1.search(nil).should == collection1
    collection1.search.should == collection1
  end

  it "returns indexed records and delegates array methods to it" do
    load_xapit_database
    member = XapitMember.new
    member.xapit_index
    collection = Xapit::Client::Collection.new
    collection.records.should == [member]
    collection.should respond_to(:flatten)
    collection.flatten.should == [member]
  end
end
