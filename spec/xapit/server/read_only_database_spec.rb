require "spec_helper"

describe Xapit::Server::ReadOnlyDatabase do
  before(:each) do
    Xapit.config[:database_path] = File.expand_path('../../../tmp/xapitdb', __FILE__)
    @changes_path = Xapit.changes_path
    FileUtils.rm(@changes_path) if File.exist? @changes_path
    @database = Xapit::Server::ReadOnlyDatabase.new(Xapit.config[:database_path])
  end

  it "should save updates to a changes file relative to database path" do
    @database.update_document("foobar")
    File.read(@changes_path).chomp.should eq('{"action":"update_document","data":"foobar"}')
  end

  it "should save removes to a changes file relative to database path" do
    @database.remove_document("foobar")
    File.read(@changes_path).chomp.should eq('{"action":"remove_document","data":"foobar"}')
  end

  it "should save adds to a changes file relative to database path" do
    @database.add_document("foobar")
    File.read(@changes_path).chomp.should eq('{"action":"add_document","data":"foobar"}')
  end
end
