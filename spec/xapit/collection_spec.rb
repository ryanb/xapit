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
      path = File.dirname(__FILE__) + '/../tmp/xapiandb'
      FileUtils.rm_rf(path) if File.exist? path
      Xapit::Config.setup(:database_path => path)
    end
    
    describe "indexed" do
      before(:each) do
        @hello = XapitMember.new(:name => "hello world")
        @foo = XapitMember.new(:name => "foo bar")
        Xapit::IndexBlueprint.index_all
      end
      
      it "should find all xapit members in database given empty string" do
        Xapit::Collection.new(XapitMember, "").should == [@hello, @foo]
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
        # this will need to be a bit more complex later...
        facet_option = Xapit::FacetOption.new
        facet_option.name = "hello world"
        Xapit::Collection.new(XapitMember, "", :facets => [facet_option.identifier]).should == [@hello]
      end
    end
  end
end
