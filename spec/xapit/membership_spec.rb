require File.dirname(__FILE__) + '/../spec_helper'

class XapitMember
  include Xapit::Membership
end

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
end
