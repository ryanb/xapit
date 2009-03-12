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
    
    it "should find all xapit members in database given empty string" do
      foo = XapitMember.new(:name => "foo")
      bar = XapitMember.new(:name => "bar")
      Xapit::IndexBlueprint.index_all(@db)
      Xapit::Collection.new(XapitMember, "", :database => @db).should == [foo, bar]
    end
  end
end
