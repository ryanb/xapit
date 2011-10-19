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

  describe "with priorities" do
    before(:each) do
      (1..5).each do |number|
        Xapit.database.add_document(:attributes => {:priority => {:value => number, :field => {}}}, :id => number, :class => "Greeting")
      end
    end

    it "fetches results matching a simple where clause" do
      query = Xapit::Server::Query.new([{:where => {:priority => 3}}])
      query.records.map { |r| r[:id] }.should eq(%w[3])
    end

    it "fetches results matching a multi where clause" do
      query = Xapit::Server::Query.new([{:where => {:priority => [3, 4]}}])
      query.records.map { |r| r[:id] }.should eq(%w[3 4])
    end

    it "fetches results matching :from and :to" do
      query = Xapit::Server::Query.new([{:where => {:priority => {:from => 2, :to => 4}}}])
      query.records.map { |r| r[:id] }.should eq(%w[2 3 4])
    end

    it "fetches results matching less than or greater than" do
      query = Xapit::Server::Query.new([{:where => {:priority => {:gte => 3}}}])
      query.records.map { |r| r[:id] }.should eq(%w[3 4 5])
      query = Xapit::Server::Query.new([{:where => {:priority => {:lte => 3}}}])
      query.records.map { |r| r[:id] }.should eq(%w[1 2 3])
    end

    it "fetches results matching exact terms" do
      query = Xapit::Server::Query.new([{:any_terms => ["Xpriority-1", "Xpriority-2"]}])
      query.records.map { |r| r[:id] }.should eq(%w[1 2])
    end
  end
end
