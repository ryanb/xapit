require "spec_helper"

describe Xapit::Client::Collection do
  it "builds up clauses with in_classes, search, where, order calls" do
    collection1 = Xapit::Client::Collection.new([:initial])
    collection2 = collection1.in_classes(String).search("hello").where(:foo => "bar").order(:bar)
    collection1.clauses.should eq([:initial])
    collection2.clauses.should eq([:initial, {:in_classes => [String]}, {:search => "hello"}, {:where => {:foo => "bar"}}, {:order => [:bar, :asc]}])
  end

  it "returns same collection when searching nil or empty string" do
    collection1 = Xapit::Client::Collection.new
    collection1.search("").should eq(collection1)
    collection1.search(nil).should eq(collection1)
    collection1.search.should eq(collection1)
  end

  it "returns indexed records and delegates array methods to it" do
    load_xapit_database
    member = XapitMember.new
    member.xapit_index
    collection = Xapit::Client::Collection.new
    collection.records.should eq([member])
    collection.should respond_to(:flatten)
    collection.flatten.should eq([member])
  end

  it "splits up matching facets into an array" do
    collection = Xapit::Client::Collection.new([]).match_facets("foo-bar")
    collection.clauses.should eq([{:match_facets => %w[foo bar]}])
  end

  it "splits range into from/to hash" do
    collection = Xapit::Client::Collection.new([]).where(:priority => 3..5)
    collection.clauses.should eq([{:where => {:priority => {:from => 3, :to => 5}}}])
  end
end
