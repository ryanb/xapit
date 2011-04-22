__END__
require "spec_helper"

describe Xapit::Collection do
  describe "with database" do
    before(:each) do
      XapitMember.xapit do |index|
        index.text :name
        index.field :name
        index.facet :name
        index.sortable :name
      end
    end

    describe "indexed" do
      before(:each) do
        @hello = XapitMember.new(:name => "hello world")
        @foo = XapitMember.new(:name => "foo bar")
        Xapit.index_all
      end

      it "should find all xapit members in database given nil" do
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

      it "should support page and per_page options" do
        Xapit::Collection.new(XapitMember, :page => 1, :per_page => 1).should == [@hello]
        Xapit::Collection.new(XapitMember, :page => 2, :per_page => 1).should == [@foo]
      end

      it "should have offset" do
        Xapit::Collection.new(XapitMember, :page => 2, :per_page => 1).offset.should == 1
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
        Xapit::Collection.new(XapitMember, :facets => ["unknownfacet"]).should be_empty
      end

      it "should find matching facet" do
        ids = Xapit::FacetBlueprint.new(XapitMember, 0, :name).identifiers_for(@hello)
        Xapit::Collection.new(XapitMember, :facets => ids*2).should == [@hello]
      end

      it "should split facets string on dash" do
        ids = Xapit::FacetBlueprint.new(XapitMember, 0, :name).identifiers_for(@hello)
        Xapit::Collection.new(XapitMember, :facets => (ids*2).join("-")).should == [@hello]
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

      it "should sort records in specified order" do
        Xapit::Collection.new(XapitMember, :order => :name).should == [@foo, @hello]
      end

      it "should have no spelling suggestions for empty query" do
        Xapit::Collection.new(XapitMember).spelling_suggestion.should == nil
      end

      it "should have no spelling suggestion for very different query" do
        Xapit::Collection.new(XapitMember, "match nothing").spelling_suggestion.should == nil
      end

      it "should have spelling suggestion for single-word query" do
        Xapit::Collection.new(XapitMember, "wrld").spelling_suggestion.should == "world"
      end

      it "should have spelling suggestion for multi-word query" do
        Xapit::Collection.new(XapitMember, "helo bat wrld").spelling_suggestion.should == "hello bar world"
      end

      it "should raise error when fetching spelling suggestion if spelling is disabled" do
        Xapit::Config.options[:spelling] = false
        lambda { Xapit::Collection.new(XapitMember, "foo").spelling_suggestion }.should raise_error
      end

      it "should find similar records" do
        member = XapitMember.new(:name => "foo bar world")
        Xapit::Collection.search_similar(member).should == [@foo, @hello]
      end

      it "should be able to specify classes" do
        Xapit::Collection.new(nil, "foo", :classes => [String, Array]).should == []
        Xapit::Collection.new(nil, "foo", :classes => [String, Array, XapitMember]).should == [@foo]
      end

      it "should support nested or_search" do
        Xapit::Collection.new(XapitMember, "world", :order => :name).or_search("foo").should == [@foo, @hello]
      end

      it "should override options in nested or_search" do
        Xapit::Collection.new(XapitMember, "world", :order => :name, :per_page => 2).or_search("foo", :per_page => 1).should == [@foo]
      end

      it "should combine multiple or_search" do
        @buz = XapitMember.new(:name => "buz")
        @zot = XapitMember.new(:name => "zot")
        Xapit.remove_database
        Xapit.index_all
        Xapit::Collection.new(XapitMember, "world", :order => :name).or_search("foo").or_search("buz").should == [@buz, @foo, @hello]
      end

      it "should support nested search" do
        @zap = XapitMember.new(:name => "zap world")
        Xapit.remove_database
        Xapit.index_all
        Xapit::Collection.new(XapitMember, "world").search("zap") == [@zap]
      end

      it "should inherit options in nested collection search" do
        Xapit::Collection.new(XapitMember, "world", :per_page => 3).search("zap").per_page.should == 3
      end
    end
  end
end
