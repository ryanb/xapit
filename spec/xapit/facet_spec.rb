__END__
require "spec_helper"

describe Xapit::Facet do
  describe "with database" do
    before(:each) do
      XapitMember.xapit do |index|
        index.facet :visible
      end
    end

    describe "indexed" do
      before(:each) do
        @visible1 = XapitMember.new(:visible => true)
        @visible2 = XapitMember.new(:visible => true)
        @invisible = XapitMember.new(:visible => false)
        Xapit.index_all
      end

      describe "facet from empty search" do
        before(:each) do
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

        it "should have identifier for options" do
          blueprint = Xapit::FacetBlueprint.new(XapitMember, 0, :visible)
          @facet.options.detect { |o| o.name == 'true' }.identifier.should == blueprint.identifiers_for(@visible1).first
          @facet.options.detect { |o| o.name == 'false' }.identifier.should == blueprint.identifiers_for(@invisible).first
        end

        it "should have matching identifiers" do
          blueprint = Xapit::FacetBlueprint.new(XapitMember, 0, :visible)
          hash = { blueprint.identifiers_for(@visible1).first => 2, blueprint.identifiers_for(@invisible).first => 1 }
          @facet.matching_identifiers.should == hash
        end

        it "should not include matching identifiers that are current" do
          blueprint = Xapit::FacetBlueprint.new(XapitMember, 0, :visible)
          @facet.existing_facet_identifiers = blueprint.identifiers_for(@visible1)
          @facet.matching_identifiers.should == { blueprint.identifiers_for(@invisible).first => 1 }
        end

        it "should return identifier on to_param" do
          blueprint = Xapit::FacetBlueprint.new(XapitMember, 0, :visible)
          @facet.options.detect { |o| o.name == 'true' }.to_param.should == blueprint.identifiers_for(@visible1).first
        end

        it "should sort options in alphabetical order" do
          @facet.options.first.name.should == 'false'
          @facet.options.last.name.should == 'true'
        end
      end

      it "should not list facets if only one option is found" do
        blueprint = Xapit::FacetBlueprint.new(XapitMember, 0, :visible)
        facets = XapitMember.search(:facets => blueprint.identifiers_for(@visible1)).facets
        facets.should be_empty
      end
    end
  end
end
