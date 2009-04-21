require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::ClassicQueryParser do
  before(:each) do
    @parser = Xapit::ClassicQueryParser.new(nil, nil)
  end
  
  it "should parse nothing for simple string" do
    expected = Xapian::QueryParser.new.parse_query("foo bar").description
    @parser.xapian_query_from_text("foo bar").description.should == expected
  end
end
