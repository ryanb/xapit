require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Xapit::Config do
  it "should be able to set database path and fetch writable or readable" do
    Xapit::Config.setup(:database_path => File.dirname(__FILE__) + '/../tmp/xapiandb')
    Xapit::Config.remove_database
    Xapit::Config.writable_database.should be_kind_of(Xapian::WritableDatabase)
    Xapit::Config.database.should be_kind_of(Xapian::Database)
  end
end
