require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Xapit::Query do
  it "should use query passed in" do
    expected = Xapian::Query.new(Xapian::Query::OP_AND, ["foo bar"])
    query = Xapit::Query.new(expected)
    query.xapian_query.should == expected
  end
  
  it "should build a query from a string parameter" do
    expected = Xapian::Query.new(Xapian::Query::OP_AND, ["foo bar"])
    query = Xapit::Query.new("foo bar")
    query.xapian_query.description.should == expected.description
  end
  
  it "should build a query from an array of strings" do
    expected = Xapian::Query.new(Xapian::Query::OP_AND, %w[foo bar])
    query = Xapit::Query.new(%w[foo bar])
    query.xapian_query.description.should == expected.description
  end
  
  it "should build a query from an array of strings with :or operator" do
    expected = Xapian::Query.new(Xapian::Query::OP_OR, %w[foo bar])
    query = Xapit::Query.new(%w[foo bar], :or)
    query.xapian_query.description.should == expected.description
  end
  
  it "should AND two queries together" do
    expected = Xapian::Query.new(Xapian::Query::OP_AND,
      Xapian::Query.new(Xapian::Query::OP_AND, ["foo"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["bar"])
    )
    query = Xapit::Query.new("foo")
    query.and_query("bar")
    query.xapian_query.description.should == expected.description
  end
  
  it "should OR two queries together" do
    expected = Xapian::Query.new(Xapian::Query::OP_OR,
      Xapian::Query.new(Xapian::Query::OP_AND, ["foo"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["bar"])
    )
    query = Xapit::Query.new("foo")
    query.or_query("bar")
    query.xapian_query.description.should == expected.description
  end
  
  it "should build a query from an array of mixed strings and queries" do
    expected = Xapian::Query.new(Xapian::Query::OP_AND,
      Xapian::Query.new(Xapian::Query::OP_AND, ["foo"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["bar"])
    )
    query = Xapit::Query.new([Xapit::Query.new("foo"), Xapian::Query.new(Xapian::Query::OP_AND, ["bar"])])
    query.xapian_query.description.should == expected.description
  end
end
