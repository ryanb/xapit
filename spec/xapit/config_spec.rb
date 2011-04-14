require "spec_helper"

describe Xapit::Config do
  it "should be able to set database path and fetch writable or readable" do
    Xapit::Config.database.writable_database.should be_kind_of(Xapian::WritableDatabase)
    Xapit::Config.database.readable_database.should be_kind_of(Xapian::Database)
  end

  it "should default query parser to SimpleQueryParser" do
    Xapit::Config.setup
    Xapit::Config.query_parser.should == Xapit::ClassicQueryParser
  end

  it "should be able to set query parser on setup" do
    Xapit::Config.setup(:query_parser => Xapit::SimpleQueryParser)
    Xapit::Config.query_parser.should == Xapit::SimpleQueryParser
  end

  it "should default indexer to SimpleIndexer" do
    Xapit::Config.setup
    Xapit::Config.indexer.should == Xapit::SimpleIndexer
  end

  it "should be able to set indexer on setup" do
    Xapit::Config.setup(:indexer => Xapit::ClassicIndexer)
    Xapit::Config.indexer.should == Xapit::ClassicIndexer
  end

  it "should have spelling enabled by default" do
    Xapit::Config.setup
    Xapit::Config.spelling?.should be_true
  end

  it "should be able to specify spelling setting at setup" do
    Xapit::Config.setup(:spelling => false)
    Xapit::Config.spelling?.should be_false
  end

  it "should default stemming to english" do
    Xapit::Config.setup
    Xapit::Config.stemming == "english"
  end

  it "should be able to specify stemming setting at setup" do
    Xapit::Config.setup(:stemming => "german")
    Xapit::Config.stemming == "german"
  end

  it "should remove the database if it is a true xapian database" do
    Xapit::Config.remove_database
    File.exist?(Xapit::Config.path).should be_false
  end

  it "should NOT remove the database if it is not a xapian database" do
    path = Xapit::Config.path + "/testing"
    FileUtils.mkdir_p(path)
    Xapit::Config.remove_database
    File.exist?(Xapit::Config.path).should be_true
    FileUtils.rm_rf(Xapit::Config.path)
  end
end
