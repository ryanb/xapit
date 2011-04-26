require "spec_helper"

describe Xapit::Server::Query do
  before(:each) do
    load_xapit_database
  end

  it "fetches results matching a simple search term" do
    Xapit.database.add_document(:attributes => {:greeting => {:value => "hello world", :text => {}}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new([{:search => "hello"}])
    query.results.should == [{:class => "Greeting", :id => "123", :relevance => 100}]
    query = Xapit::Server::Query.new([{:search => "matchnothing"}])
    query.results.should == []
  end

  it "parses where clause into field terms" do
    query = Xapit::Server::Query.new([{:where => {:greeting => "Hello"}}, {:where => {:age => 23}}])
    query.field_terms.should include("Xgreeting-hello", "Xage-23")
  end

  it "parses search clause into search terms" do
    query = Xapit::Server::Query.new([{:search => "hello world"}, {:search => "foo"}])
    query.search_terms.should include("hello world", "foo")
  end
end
