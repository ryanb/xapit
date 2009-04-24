require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::ClassicQueryParser do
  before(:each) do
    @parser = Xapit::ClassicQueryParser.new(nil, nil)
  end
  
  it "should have an initial xapian parser with stemming and default operator support" do
    expected = Xapian::QueryParser.new
    expected.stemmer = Xapian::Stem.new("english")
    expected.stemming_strategy = Xapian::QueryParser::STEM_SOME
    expected.default_op = Xapian::Query::OP_AND
    @parser.xapian_query_from_text("foo bar").description.should == expected.parse_query("foo bar").description
  end
end
