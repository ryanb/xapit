if ENV["MODEL_ADAPTER"].nil? || ENV["MODEL_ADAPTER"] == "active_record"
  require "spec_helper"

  describe Xapit::ActiveRecordAdapter do
    it "should be used for ActiveRecord::Base subclasses" do
      Xapit::ActiveRecordAdapter.should_not be_for_class(Object)
      klass = Object.new
      stub(klass).ancestors { ["ActiveRecord::Base"] }
      Xapit::ActiveRecordAdapter.should be_for_class(klass)
    end
  
    it "should pass find_single to find method to target" do
      target = Object.new
      mock(target).find_by_id(1, :conditions => "foo") { :record }
      adapter = Xapit::ActiveRecordAdapter.new(target)
      adapter.find_single(1, :conditions => "foo").should == :record
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
end
