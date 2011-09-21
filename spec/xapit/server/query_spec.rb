require "spec_helper"

describe Xapit::Server::Query do
  before(:each) do
    load_xapit_database
  end

  it "fetches results matching a simple search term" do
    Xapit.database.add_document(:attributes => {:greeting => {:value => "hello world", :text => {}}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new([{:search => "hello"}])
    query.records.should eq([{:class => "Greeting", :id => "123", :relevance => 100}])
    query = Xapit::Server::Query.new([{:search => "matchnothing"}])
    query.records.should eq([])
  end

  it "fetches results matching a simple where clause" do
    Xapit.database.add_document(:attributes => {:priority => {:value => "3", :field => {}}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new([{:where => {:priority => 3}}])
    query.records.should eq([{:class => "Greeting", :id => "123", :relevance => 100}])
    query = Xapit::Server::Query.new([{:where => {:priority => 4}}])
    query.records.should eq([])
  end

  it "fetches results matching a multi where clause" do
    Xapit.database.add_document(:attributes => {:priority => {:value => "3", :field => {}}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new([{:where => {:priority => [3, 4]}}])
    query.records.should eq([{:class => "Greeting", :id => "123", :relevance => 66}])
  end

  it "fetches facets when told to include them" do
    Xapit.database.add_document(:attributes => {:priority => {:value => "3", :facet => {}}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new([{:include_facets => [:priority]}])
    query.facets.should eq(:priority => [{:value => "3", :count => 1}])
  end

  it "fetches results matching a given facet" do
    Xapit.database.add_document(:attributes => {:priority => {:value => "3", :field => {}, :facet => {}}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new([{:with_facets => [Xapit.facet_identifier(:priority, "3")]}])
    query.records.should eq([{:class => "Greeting", :id => "123", :relevance => 100}])
    query = Xapit::Server::Query.new([{:with_facets => [Xapit.facet_identifier(:priority, "4")]}])
    query.records.should eq([])
  end

  it "fetches results containing applied facets" do
    Xapit.database.add_document(:attributes => {:priority => {:value => "3", :facet => {}}}, :id => 123, :class => "Greeting")
    query = Xapit::Server::Query.new([{:with_facets => [Xapit.facet_identifier(:priority, "3")]}])
    query.applied_facet_options.should eq([{:id => Xapit.facet_identifier(:priority, "3"), :name => "priority", :value => "3"}])
  end
end
