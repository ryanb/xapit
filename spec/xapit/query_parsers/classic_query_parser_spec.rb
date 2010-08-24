require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::ClassicQueryParser do
  before(:each) do
    @parser = Xapit::ClassicQueryParser.new(nil, nil)
  end
  
  it "should have an initial xapian parser with stemming and default operator support" do
    Xapit::Config.writable_database # just so a database exists
    expected = Xapian::QueryParser.new
    expected.stemmer = Xapian::Stem.new("english")
    expected.stemming_strategy = Xapian::QueryParser::STEM_SOME
    expected.default_op = Xapian::Query::OP_AND
    @parser.xapian_query_from_text("foo bar").description.should == expected.parse_query("foo bar").description
  end
  
  it "should remove asterisks from terms with one letter" do
    @parser.cleanup_text("J*").should == "J"
  end
  
  it "should strip out punctuation other than asterisk and colon" do
    @parser.cleanup_text("a- b':cd*").should == "a b:cd*"
  end
end
