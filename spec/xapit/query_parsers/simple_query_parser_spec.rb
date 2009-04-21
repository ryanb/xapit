require File.dirname(__FILE__) + '/../../spec_helper'

describe Xapit::SimpleQueryParser do
  it "should parse nothing for simple string" do
    Xapit::SimpleQueryParser.new(nil, "foobar").parsed.should == "foobar"
  end
  
  it "should parse empty string as blank string" do
    Xapit::SimpleQueryParser.new(nil, "").parsed.should == ""
    Xapit::SimpleQueryParser.new(nil, "  \t  ").parsed.should == ""
  end
  
  it "should parse white space as AND" do
    Xapit::SimpleQueryParser.new(nil, "foo bar").parsed.should == [:and, "foo", "bar"]
    Xapit::SimpleQueryParser.new(nil, "\t foo  \t bar  ").parsed.should == [:and, "foo", "bar"]
  end
  
  it "should parse simple 'or' query" do
    Xapit::SimpleQueryParser.new(nil, "foo or bar").parsed.should == [:or, "foo", "bar"]
    Xapit::SimpleQueryParser.new(nil, " foo or\t bar \t ").parsed.should == [:or, "foo", "bar"]
    Xapit::SimpleQueryParser.new(nil, "foo OR bar").parsed.should == [:or, "foo", "bar"]
  end
  
  it "should parse 'and' within 'or' giving 'or' presedence" do
    Xapit::SimpleQueryParser.new(nil, "foo or bar blah").parsed.should == [:or, "foo", [:and, "bar", "blah"]]
    Xapit::SimpleQueryParser.new(nil, "foo bar or blah").parsed.should == [:or, [:and, "foo", "bar"], "blah"]
  end
  
  it "should parse simple 'not' query" do
    Xapit::SimpleQueryParser.new(nil, "foo not bar").parsed.should == [:and, "foo", [:not, "bar"]]
    Xapit::SimpleQueryParser.new(nil, "foo  NOT  bar blah").parsed.should == [:and, "foo", [:not, "bar"], "blah"]
  end
  
  it "should convert simple query to xapian query" do
    Xapit::SimpleQueryParser.new(nil, "foo bar").xapian_query.description.should == Xapian::Query.new(Xapian::Query::OP_AND, "foo", "bar").description
    Xapit::SimpleQueryParser.new(nil, "foo OR bar").xapian_query.description.should == Xapian::Query.new(Xapian::Query::OP_OR, "foo", "bar").description
  end
  
  it "should convert deep query to xapian query" do
    query = Xapian::Query.new(Xapian::Query::OP_OR,
      Xapian::Query.new(Xapian::Query::OP_OR, ["foo"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["bar", "blah"])
    )
    Xapit::SimpleQueryParser.new(nil, "foo or bar blah").xapian_query.description.should == query.description
  end
  
  it "should convert multi-deep query to xapian query" do
    query = Xapian::Query.new(Xapian::Query::OP_OR,
      Xapian::Query.new(Xapian::Query::OP_AND, ["foo", "bar"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["test", "blah"])
    )
    Xapit::SimpleQueryParser.new(nil, "foo bar or test blah").xapian_query.description.should == query.description
  end
  
  it "should convert single word query to xapian query" do
    Xapit::SimpleQueryParser.new(nil, "foo").xapian_query.description.should == Xapian::Query.new(Xapian::Query::OP_AND, ["foo"]).description
  end
  
  it "should convert negative query to xapian query" do
    query = Xapian::Query.new(Xapian::Query::OP_AND_NOT,
      Xapian::Query.new(Xapian::Query::OP_AND, ["foo"]),
      Xapian::Query.new(Xapian::Query::OP_AND, ["bar"])
    )
    Xapit::SimpleQueryParser.new(nil, "foo not bar").xapian_query.description.should == query.description
  end
  
  it "should not modify parsed array when fetching xapian query" do
    pending
    query = Xapit::SimpleQueryParser.new("hello world").and_query("foo bar")
    query.xapian_query
    query.parsed.should == [:and, [:and, "hello", "world"], [:and, "foo", "bar"]]
  end
end
