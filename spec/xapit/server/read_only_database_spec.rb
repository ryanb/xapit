require "spec_helper"

describe Xapit::Server::ReadOnlyDatabase do
  before(:each) do
    @path = File.expand_path('../../../tmp/xapitdb', __FILE__)
    @changes_path = "#{@path}_changes"
    FileUtils.rm(@changes_path)
    @database = Xapit::Server::ReadOnlyDatabase.new(@path)
  end

  it "should save updates to a changes file relative to database path" do
    @database.update_document("foobar")
    File.read(@changes_path).chomp.should eq('{"action":"update","data":"foobar"}')
  end

  it "should save removes to a changes file relative to database path" do
    @database.remove_document("foobar")
    File.read(@changes_path).chomp.should eq('{"action":"remove","data":"foobar"}')
  end

  it "should save adds to a changes file relative to database path" do
    @database.add_document("foobar")
    File.read(@changes_path).chomp.should eq('{"action":"add","data":"foobar"}')
  end
end
