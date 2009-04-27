require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class OtherMember
  include Xapit::Membership
end

describe XapitMember do
  it "should have xapit method" do
    OtherMember.should respond_to(:xapit)
  end
  
  it "should not respond to xapit_index_blueprint if xapit isn't called" do
    OtherMember.should_not respond_to(:xapit_index_blueprint)
    OtherMember.should_not respond_to(:search)
    OtherMember.new.should_not respond_to(:search_similar)
    OtherMember.new.should_not respond_to(:xapit_relevance)
  end
  
  describe "with description indexed" do
    before(:each) do
      XapitMember.xapit do |index|
        index.text :description
      end
    end
    
    it "should have xapit index blueprint" do
      XapitMember.xapit_index_blueprint.should be_kind_of(Xapit::IndexBlueprint)
    end
    it "should return collection from search" do
      XapitMember.search("foo").class.should == Xapit::Collection
    end
  
    it "should store xapit_relevance" do
      member = XapitMember.new
      member.xapit_relevance = 123
      member.xapit_relevance.should == 123
    end
  end
end
