require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe XapitMember do
  it "should have xapit method" do
    XapitMember.should respond_to(:xapit)
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
