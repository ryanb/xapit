require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::Facet do
  describe "with database" do
    before(:each) do
      XapitMember.delete_all
      XapitMember.xapit do |index|
        index.facet :visible
      end
      path = File.dirname(__FILE__) + '/../tmp/xapiandb'
      FileUtils.rm_rf(path) if File.exist? path
      Xapit::Config.setup(:database_path => path)
    end
    
    describe "indexed" do
      before(:each) do
        @visible1 = XapitMember.new(:visible => true)
        @visible2 = XapitMember.new(:visible => true)
        @invisible = XapitMember.new(:visible => false)
        Xapit::IndexBlueprint.index_all
        @facet = XapitMember.search("").facets.first
      end
      
      it "should have the name of 'Visible'" do
        @facet.name.should == 'Visible'
      end
      
      it "should have true and false options" do
        @facet.options.map(&:name).sort.should == %w[false true]
      end
      
      it "should have record count" do
        @facet.options.detect { |o| o.name == 'true' }.count.should == 2
        @facet.options.detect { |o| o.name == 'false' }.count.should == 1
      end
    end
  end
end
