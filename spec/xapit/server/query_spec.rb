require "spec_helper"

describe Xapit::Server::Query do
  before(:each) do
    @database = blank_xapit_database
  end

  it "fetches results matching a simple search term" do
    @database.add_document(:texts => {:greeting => {:value => "hello world"}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new(@database, [{:search => ["hello"]}])
    query.results.should == [{:class => "Greeting", :id => "123", :relevance => 100}]
    query = Xapit::Server::Query.new(@database, [{:search => ["matchnothing"]}])
    query.results.should == []
  end
end
