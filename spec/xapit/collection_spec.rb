require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::Collection do
  describe "with database" do
    before(:each) do
      XapitMember.delete_all
      XapitMember.xapit do |index|
        index.text :name
        index.field :name
      end
      path = File.dirname(__FILE__) + '/../tmp/xapiandb'
      FileUtils.rm_rf(path) if File.exist? path
      @db = Xapian::WritableDatabase.new(path, Xapian::DB_CREATE_OR_OVERWRITE)
    end
    
    describe "indexed" do
      before(:each) do
        @hello = XapitMember.new(:name => "hello world")
        @foo = XapitMember.new(:name => "foo bar")
        Xapit::IndexBlueprint.index_all(@db)
      end
      
      it "should find all xapit members in database given empty string" do
        Xapit::Collection.new(XapitMember, "", :database => @db).should == [@hello, @foo]
      end
      
      it "should matching xapit member given a word" do
        Xapit::Collection.new(XapitMember, "foo", :database => @db).should == [@foo]
      end
      
      it "should not be case sensitive on query matching" do
        Xapit::Collection.new(XapitMember, "BAR Foo", :database => @db).should == [@foo]
      end
      
      it "should have 2 records for empty string" do
        Xapit::Collection.new(XapitMember, "", :database => @db).size.should == 2
      end
      
      it "should not be empty for blank query" do
        Xapit::Collection.new(XapitMember, "", :database => @db).empty?.should be_false
      end
      
      it "should filter by conditions, case insensitive" do
        Xapit::Collection.new(XapitMember, "", :database => @db, :conditions => { :name => "HELLO world"}).should == [@hello]
      end
      
      it "should know first entry" do
        Xapit::Collection.new(XapitMember, "", :database => @db).first.should == @hello
      end
      
      it "should know last entry" do
        Xapit::Collection.new(XapitMember, "", :database => @db).last.should == @foo
      end
      
      it "should support nested search" do
        Xapit::Collection.new(XapitMember, "world", :database => @db).search("foo") == [@foo]
      end
      
      it "should support page and per_page options" do
        Xapit::Collection.new(XapitMember, "", :database => @db, :page => 1, :per_page => 1).should == [@hello]
        Xapit::Collection.new(XapitMember, "", :database => @db, :page => 2, :per_page => 1).should == [@foo]
      end
      
      it "should have total_entries, total_pages, current_page, per_page, previous_page, next_page" do
        collection = Xapit::Collection.new(XapitMember, "", :database => @db, :per_page => 1, :page => 2)
        collection.total_entries.should == 2
        collection.total_pages.should == 2
        collection.previous_page.should == 1
        collection.next_page.should be_nil
      end
    end
  end
end
