require "spec_helper"

describe Xapit::FacetOption do
  it "should combine previous identifiers with current one on to_param" do
    option = Xapit::FacetOption.new(nil, nil, nil)
    option.existing_facet_identifiers = ["abc", "123"]
    stub(option).identifier { "foo" }
    option.to_param.should == "abc-123-foo"
  end

  it "should remove current identifier from previous identifiers if it exists" do
    Xapit.setup(:breadcrumb_facets => false)
    option = Xapit::FacetOption.new(nil, nil, nil)
    option.existing_facet_identifiers = ["abc", "123", "foo"]
    stub(option).identifier { "foo" }
    option.to_param.should == "abc-123"
  end

  it "should support breadcrumb style facets" do
    Xapit.setup(:breadcrumb_facets => true)
    option = Xapit::FacetOption.new(nil, nil, nil)
    option.existing_facet_identifiers = ["abc", "123", "foo"]
    stub(option).identifier { "123" }
    option.to_param.should == "abc-123"
  end

  describe "with database" do
    before(:each) do
      XapitMember.xapit do |index|
        index.facet :age, "Person Age"
        index.facet :category
      end
    end

    it "should have identifier hashing name and value" do
      option = Xapit::FacetOption.new("XapitMember", "age", "17")
      option.identifier.should == "0c93ee1"
    end

    it "should find facet option from database given id" do
      doc = Xapit::Document.new
      doc.data = "XapitMember|||age|||17"
      doc.terms << "QXapit::FacetOption-abc123"
      Xapit::Config.database.add_document(doc)
      option = Xapit::FacetOption.find("abc123")
      option.name.should == "17"
      option.facet.name.should == "Person Age"
    end

    it "should save facet to database" do
      Xapit::Config.database.xapian_database # make sure there's a database setup in case we try to read from it
      option = Xapit::FacetOption.new(nil, nil, nil)
      option.facet = XapitMember.xapit_facet_blueprint("age")
      option.name = "23"
      option.save
      Xapit::FacetOption.find(option.identifier).should_not be_nil
    end

    it "should not save facet if it already exists" do
      doc = Xapit::Document.new
      doc.data = "XapitMember|||age|||17"
      doc.terms << "QXapit::FacetOption-abc123"
      Xapit::Config.database.add_document(doc)
      stub(Xapit::Config.database).add_document { raise "should not add doc" }
      option = Xapit::FacetOption.new(XapitMember, nil, nil)
      stub(option).identifier { "abc123" }
      option.save
    end

    it "should find facet option which doesn't have a value" do
      doc = Xapit::Document.new
      doc.data = "XapitMember|||age|||"
      doc.terms << "QXapit::FacetOption-abc123"
      Xapit::Config.database.add_document(doc)
      option = Xapit::FacetOption.find("abc123")
      option.name.should == ""
      option.facet.name.should == "Person Age"
    end
  end
end
