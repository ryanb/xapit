require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::AbstractQueryParser do
  before(:each) do
  end
    
  it "should parse conditions hash into terms" do
    parser = Xapit::AbstractQueryParser.new(:conditions => { :foo => 'bar', 'hello' => :world })
    parser.condition_terms.sort.should == ["Xfoo-bar", "Xhello-world"].sort
  end
    
  it "should convert time into integer before placing in condition term" do
    time = Time.now
    parser = Xapit::AbstractQueryParser.new(:conditions => { :time => time })
    parser.condition_terms.should == ["Xtime-#{time.to_i}"]
  end
    
  it "should convert date into time then integer before placing in condition term" do
    date = Date.today
    parser = Xapit::AbstractQueryParser.new(:conditions => { :date => date })
    parser.condition_terms.should == ["Xdate-#{date.to_time.to_i}"]
  end
    
  it "should give spelling suggestion on full term" do
    Xapit::Config.database.add_spelling("foo bar")
    parser = Xapit::AbstractQueryParser.new(nil, "foo barr")
    parser.spelling_suggestion.should == "foo bar"
  end
    
  it "should allow an array of conditions to be specified and use OR xapian query." do
    parser = Xapit::AbstractQueryParser.new(:not_conditions => { :foo => %w[hello world]})
    parser.not_condition_terms.first.xapian_query.description.should == Xapit::Query.new(%w[Xfoo-hello Xfoo-world], :or).xapian_query.description
  end
    
  it "should allow range condition to be specified and use VALUE_RANGE xapian query." do
    XapitMember.xapit { |i| i.field :foo }
    expected = Xapian::Query.new(Xapian::Query::OP_VALUE_RANGE, 0, Xapian.sortable_serialise(2), Xapian.sortable_serialise(5))
    parser = Xapit::AbstractQueryParser.new(XapitMember, :conditions => { :foo => 2..5 })
    parser.condition_terms.first.description.should == expected.description
  end
    
  it "should allow range condition to be specified in array." do
    XapitMember.xapit { |i| i.field :foo }
    expected = Xapian::Query.new(Xapian::Query::OP_OR,
      Xapian::Query.new(Xapian::Query::OP_VALUE_RANGE, 0, Xapian.sortable_serialise(2), Xapian.sortable_serialise(5)),
      Xapian::Query.new(Xapian::Query::OP_AND, ["Xfoo-10"])
    )
    parser = Xapit::AbstractQueryParser.new(XapitMember, :conditions => { :foo => [2..5, 10] })
    parser.condition_terms.first.xapian_query.description.should == expected.description
  end
    
  it "should expand punctuated terms properly" do
    XapitMember.xapit { |i| i.field :name }
    bar = XapitMember.new(:name => "foo-bar")
    baz = XapitMember.new(:name => "foo-baz")
    zap = XapitMember.new(:name => "foo-zap")
    Xapit.index_all
    XapitMember.search(:conditions => { :name => "foo-b*"}).should == [bar, baz]
  end
end
