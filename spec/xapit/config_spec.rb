require File.dirname(__FILE__) + '/../spec_helper'

describe Xapit::Config do
  it "should be able to set database path and fetch writable or readable" do
    path = File.dirname(__FILE__) + '/../tmp/xapiandb'
    FileUtils.rm_rf(path) if File.exist? path
    Xapit::Config.setup(:database_path => path)
    Xapit::Config.writable_database.should be_kind_of(Xapian::WritableDatabase)
    Xapit::Config.database.should be_kind_of(Xapian::Database)
  end
end
