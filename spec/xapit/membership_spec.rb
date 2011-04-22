__END__
require "spec_helper"

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
      XapitMember.instance_variable_set("@xapit_adapter", nil)
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

    it "should have a xapit document" do
      member = XapitMember.new(:description => "foo")
      member.xapit_document.terms = %w[foo]
    end

    it "should have an adapter" do
      XapitMember.xapit_adapter.class.should == Xapit::ActiveRecordAdapter
    end

    it "should use DataMapper adapter if that is ancestor" do
      stub(XapitMember).ancestors { ["DataMapper::Resource"] }
      XapitMember.xapit_adapter.class.should == Xapit::DataMapperAdapter
    end

    it "should raise an exception when no adapter is found" do
      stub(XapitMember).ancestors { [] }
      lambda { XapitMember.xapit_adapter }.should raise_error
    end
  end
end
