require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::Query do
  it "should parse nothing for simple string" do
    Xapit::Query.new("foobar").parsed.should == "foobar"
  end
  
  it "should parse empty string as blank string" do
    Xapit::Query.new("").parsed.should == ""
    Xapit::Query.new("  \t  ").parsed.should == ""
  end
  
  it "should parse white space as AND" do
    Xapit::Query.new("foo bar").parsed.should == [:and, "foo", "bar"]
    Xapit::Query.new("\t foo  \t bar  ").parsed.should == [:and, "foo", "bar"]
  end
  
  it "should parse simple 'or' query" do
    Xapit::Query.new("foo or bar").parsed.should == [:or, "foo", "bar"]
    Xapit::Query.new(" foo or\t bar \t ").parsed.should == [:or, "foo", "bar"]
    Xapit::Query.new("foo OR bar").parsed.should == [:or, "foo", "bar"]
  end
  
  it "should parse 'and' within 'or' giving 'or' presedence" do
    Xapit::Query.new("foo or bar blah").parsed.should == [:or, "foo", [:and, "bar", "blah"]]
    Xapit::Query.new("foo bar or blah").parsed.should == [:or, [:and, "foo", "bar"], "blah"]
  end
  
  it "should parse array as normal args" do
    Xapit::Query.new(["foo", "bar"]).parsed.should == [:and, "foo", "bar"]
  end
  
  it "should parse simple 'not' query" do
    Xapit::Query.new("foo not bar").parsed.should == [:and, "foo", [:not, "bar"]]
    Xapit::Query.new("foo  NOT  bar blah").parsed.should == [:and, "foo", [:not, "bar"], "blah"]
  end
  
  it "should convert simple query to xapian query" do
    Xapit::Query.new("foo bar").xapian_query.description.should == Xapian::Query.new(Xapian::Query::OP_AND, "foo", "bar").description
    Xapit::Query.new("foo OR bar").xapian_query.description.should == Xapian::Query.new(Xapian::Query::OP_OR, "foo", "bar").description
  end
  
  it "should convert deep query to xapian query" do
    query = Xapian::Query.new(Xapian::Query::OP_OR,
      Xapian::Query.new(Xapian::Query::OP_OR, ["foo"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["bar", "blah"])
    )
    Xapit::Query.new("foo or bar blah").xapian_query.description.should == query.description
  end
  
  it "should convert multi-deep query to xapian query" do
    query = Xapian::Query.new(Xapian::Query::OP_OR,
      Xapian::Query.new(Xapian::Query::OP_AND, ["foo", "bar"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["test", "blah"])
    )
    Xapit::Query.new("foo bar or test blah").xapian_query.description.should == query.description
  end
  
  it "should convert single word query to xapian query" do
    Xapit::Query.new("foo").xapian_query.description.should == Xapian::Query.new(Xapian::Query::OP_AND, ["foo"]).description
  end
  
  it "should convert negative query to xapian query" do
    query = Xapian::Query.new(Xapian::Query::OP_AND_NOT,
      Xapian::Query.new(Xapian::Query::OP_AND, ["foo"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["bar"])
    )
    Xapit::Query.new("foo not bar").xapian_query.description.should == query.description
  end
  
  it "should add query to parsed one" do
    query = Xapit::Query.new("foo bar")
    query.and_query("test")
    query.parsed.should == [:and, [:and, "foo", "bar"], "test"]
  end
  
  it "should apply 'or' query to parsed" do
    query = Xapit::Query.new("foo")
    query.or_query("bar")
    query.parsed.should == [:or, "foo", "bar"]
  end
end
