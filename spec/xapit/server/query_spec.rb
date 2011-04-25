require "spec_helper"

describe Xapit::Server::Query do
  before(:each) do
    load_xapit_database
  end

  it "fetches results matching a simple search term" do
    Xapit.database.add_document(:texts => {:greeting => {:value => "hello world"}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new([{:search => ["hello"]}])
    query.results.should == [{:class => "Greeting", :id => "123", :relevance => 100}]
    query = Xapit::Server::Query.new([{:search => ["matchnothing"]}])
    query.results.should == []
  end
end
