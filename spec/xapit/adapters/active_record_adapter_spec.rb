require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Xapit::ActiveRecordAdapter do
  it "should pass find_single to find method to target" do
    target = Object.new
    mock(target).find(1) { :record }
    adapter = Xapit::ActiveRecordAdapter.new(target)
    adapter.find_single(1).should == :record
  end
  
  it "should pass find_multiple to find method to target" do
    target = Object.new
    mock(target).find([1, 2]) { :record }
    adapter = Xapit::ActiveRecordAdapter.new(target)
    adapter.find_multiple([1, 2]).should == :record
  end
  
  it "should pass find_each to target" do
    target = Object.new
    mock(target).find_each(:args) { 5 }
    adapter = Xapit::ActiveRecordAdapter.new(target)
    adapter.find_each(:args).should == 5
  end
end
