require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Xapit::IndexBlueprint do
  before(:each) do
    XapitMember.xapit { } # call so methods are generated
    @index = Xapit::IndexBlueprint.new(XapitMember)
  end
  
  it "should remember text attributes" do
    @index.text(:foo)
    @index.text(:bar, :blah)
    @index.text(:custom) { |t| t*t }
    @index.text_attributes.keys.should include(:foo, :bar, :blah, :custom)
    @index.text_attributes[:foo][:proc].should be_nil
    @index.text_attributes[:custom][:proc].should be_kind_of(Proc)
  end
  
  it "should remember field attributes" do
    @index.field(:foo)
    @index.field(:bar, :blah)
    @index.field_attributes.should include(:foo, :bar, :blah)
  end
  
  it "should remember facets" do
    @index.facet(:foo)
    @index.facet(:bar, "Baz")
    @index.facets.map(&:name).should == ["Foo", "Baz"]
  end
  
  it "should remember sortable attributes" do
    @index.sortable(:foo)
    @index.sortable(:bar, :blah)
    @index.sortable_attributes.should include(:foo, :bar, :blah)
  end
  
  it "should have a sortable position offset by facets" do
    @index.facet(:foo)
    @index.facet(:test)
    @index.sortable(:bar, :blah)
    @index.position_of_sortable(:blah).should == 3
  end
  
  it "should have a field position offset by facets + sortable" do
    @index.facet(:foo)
    @index.sortable(:bar, :blah)
    @index.field(:bar, :blah)
    @index.position_of_field(:blah).should == 4
  end
  
  it "should index member document into database" do
    XapitMember.new
    @index.index_all
    Xapit::Config.writable_database.doccount.should >= 1
    Xapit::Config.writable_database.flush
  end
  
  it "should remember all blueprints and index each of them" do
    stub(Xapit::Config.writable_database).add_document
    mock(@index).index_all
    Xapit::IndexBlueprint.index_all
  end
  
  it "should pass in extra arguments to each method" do
    index = Xapit::IndexBlueprint.new(XapitMember, :foo, :bar => :blah)
    mock(XapitMember).find_each(:foo, :bar => :blah)
    index.index_all
  end
  
  it "should add a record from the index" do
    member = XapitMember.new(:name => "New Record!")
    @index.text :name
    @index.create_record(member.id)
    XapitMember.search("New Record").should == [member]
  end
  
  it "should remove a record from the index" do
    member = XapitMember.new(:name => "Bad Record!")
    @index.text :name
    @index.index_all
    @index.destroy_record(member.id)
    XapitMember.search("Bad Record").should == []
  end
  
  it "should update a record in the index" do
    member = XapitMember.new(:name => "New Record!")
    @index.text :name
    @index.index_all
    member.update_attribute(:name, "Changed Record!")
    @index.update_record(member.id)
    XapitMember.search("Changed Record").should == [member]
  end
  
  it "should not create record index if member isn't found" do
    Xapit::Config.writable_database # make sure the database is built
    member = XapitMember.new(:name => "New Record!")
    stub(XapitMember).find { nil }
    @index.text :name
    @index.create_record(member.id)
    XapitMember.search("New Record").should be_empty
  end
  
  it "should remove record from index when updating a member which doesn't exist" do
    member = XapitMember.new(:name => "New Record!")
    @index.text :name
    @index.index_all
    stub(XapitMember).find { nil }
    member.update_attribute(:name, "Changed Record!")
    @index.update_record(member.id)
    XapitMember.search("New Record").should be_empty
    XapitMember.search("Changed Record").should be_empty
  end
end
