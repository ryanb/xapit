require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::Collection do
  describe "with database" do
    before(:each) do
      XapitMember.delete_all
      XapitMember.xapit do |index|
        index.text :name
        index.field :name
        index.facet :name
      end
      Xapit::Config.setup(:database_path => File.dirname(__FILE__) + '/../tmp/xapiandb')
      Xapit::Config.remove_database
    end
    
    describe "indexed" do
      before(:each) do
        @hello = XapitMember.new(:name => "hello world")
        @foo = XapitMember.new(:name => "foo bar")
        Xapit.index_all
      end
      
      it "should find all xapit members in database given empty string" do
        Xapit::Collection.new(XapitMember, nil).should == [@hello, @foo]
      end
      
      it "should matching xapit member given a word" do
        Xapit::Collection.new(XapitMember, "foo").should == [@foo]
      end
      
      it "should not be case sensitive on query matching" do
        Xapit::Collection.new(XapitMember, "BAR Foo").should == [@foo]
      end
      
      it "should have 2 records for empty string" do
        Xapit::Collection.new(XapitMember, "").size.should == 2
      end
      
      it "should not be empty for blank query" do
        Xapit::Collection.new(XapitMember, "").empty?.should be_false
      end
      
      it "should filter by conditions, case insensitive" do
        Xapit::Collection.new(XapitMember, "", :conditions => { :name => "HELLO world"}).should == [@hello]
      end
      
      it "should know first entry" do
        Xapit::Collection.new(XapitMember, "").first.should == @hello
      end
      
      it "should know last entry" do
        Xapit::Collection.new(XapitMember, "").last.should == @foo
      end
      
      it "should support nested search" do
        Xapit::Collection.new(XapitMember, "world").search("foo") == [@foo]
      end
      
      it "should support page and per_page options" do
        Xapit::Collection.new(XapitMember, "", :page => 1, :per_page => 1).should == [@hello]
        Xapit::Collection.new(XapitMember, "", :page => 2, :per_page => 1).should == [@foo]
      end
      
      it "should have total_entries, total_pages, current_page, per_page, previous_page, next_page" do
        collection = Xapit::Collection.new(XapitMember, "", :per_page => 1, :page => 2)
        collection.total_entries.should == 2
        collection.total_pages.should == 2
        collection.previous_page.should == 1
        collection.next_page.should be_nil
      end
      
      it "should set xapit_relevance in results" do
        results = Xapit::Collection.new(XapitMember, "")
        results.each do |record|
          record.xapit_relevance.class.should == Fixnum
        end
      end
      
      it "should find nothing when searching unknown facet" do
        Xapit::Collection.new(XapitMember, "", :facets => ["unknownfacet"]).should be_empty
      end
      
      it "should find matching facet" do
        ids = Xapit::FacetBlueprint.new(XapitMember, 0, :name).identifiers_for(@hello)
        Xapit::Collection.new(XapitMember, "", :facets => ids*2).should == [@hello]
      end
      
      it "should split facets string on dash" do
        ids = Xapit::FacetBlueprint.new(XapitMember, 0, :name).identifiers_for(@hello)
        Xapit::Collection.new(XapitMember, "", :facets => (ids*2).join("-")).should == [@hello]
      end
      
      it "should have one facet with two options with blank keywords" do
        facets = Xapit::Collection.new(XapitMember, "").facets
        facets.size.should == 1
        facets.first.options.size.should == 2
      end
      
      it "should have no applied facets when there are no given facets" do
        Xapit::Collection.new(XapitMember, "").applied_facet_options.should be_empty
      end
      
      it "should list applied facets" do
        ids = Xapit::FacetBlueprint.new(XapitMember, 0, :name).identifiers_for(@hello)
        results = Xapit::Collection.new(XapitMember, "", :facets => (ids*2).join("-"))
        results.applied_facet_options.map(&:name).should == ["hello world", "hello world"]
      end
      
      it "should pass existing facet identifiers to applied options" do
        ids = Xapit::FacetBlueprint.new(XapitMember, 0, :name).identifiers_for(@hello)
        results = Xapit::Collection.new(XapitMember, "", :facets => (ids*2).join("-"))
        results.applied_facet_options.first.existing_facet_identifiers.should == (ids*2)
      end
    end
  end
end
