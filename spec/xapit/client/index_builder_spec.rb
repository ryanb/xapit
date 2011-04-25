require "spec_helper"

describe Xapit::Client::IndexBuilder do
  it "stores text attributes with weight" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text(:foo, :weight => 3)
    builder.text(:bar, :blah)
    builder.text_attributes.keys.map(&:to_s).sort.should == %w[foo bar blah].sort
    builder.text_attributes[:foo].should == {:weight => 3}
    builder.text_attributes[:bar].should == {}
  end

  it "indexes an object by adding it to the current database" do
    load_xapit_database
    Xapit.database.xapian_database.doccount.should == 0
    builder = Xapit::Client::IndexBuilder.new
    member = XapitMember.new(:greeting => "Hello world")
    builder.index(member)
    Xapit.database.xapian_database.doccount.should == 1
  end
end
