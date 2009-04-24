require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::AbstractQueryParser do
  before(:each) do
  end
    
  it "parse conditions hash into terms" do
    parser = Xapit::AbstractQueryParser.new(:conditions => { :foo => 'bar', 'hello' => :world })
    parser.condition_terms.sort.should == ["Xfoo-bar", "Xhello-world"].sort
  end
    
  it "convert time into integer before placing in condition term" do
    time = Time.now
    parser = Xapit::AbstractQueryParser.new(:conditions => { :time => time })
    parser.condition_terms.should == ["Xtime-#{time.to_i}"]
  end
    
  it "convert date into time then integer before placing in condition term" do
    date = Date.today
    parser = Xapit::AbstractQueryParser.new(:conditions => { :date => date })
    parser.condition_terms.should == ["Xdate-#{date.to_time.to_i}"]
  end
end
