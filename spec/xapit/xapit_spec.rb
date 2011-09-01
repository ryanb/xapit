require "spec_helper"

describe Xapit do
  it "has default config settings" do
    Xapit.config[:enabled].should eq(true)
    Xapit.config[:spelling].should eq(true)
    Xapit.config[:stemming].should eq("english")
  end

  it "can be enabled" do
    Xapit.config[:enabled] = false
    Xapit.enable
    Xapit.config[:enabled].should eq(true)
  end

  it "loads and reloads a configuration file via load_config" do
    Xapit.load_config("spec/fixtures/xapit.yml", "development")
    Xapit.config[:database_path].should eq("development_database")
    Xapit.config[:database_path] = "foo"
    Xapit.reload
    Xapit.config[:database_path].should eq("development_database")
  end

  it "raises an exception when accessing the database while disabled" do
    Xapit.config[:enabled] = false
    lambda { Xapit.database }.should raise_exception(Xapit::Disabled)
  end

  it "allows changing the query class" do
    Xapit.query_class.should eq(Xapit::Server::Query)
    Xapit.config[:query_class] = "String"
    Xapit.query_class.should eq(String)
  end
end
