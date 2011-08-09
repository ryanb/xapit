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

  it "loads a simple configuration file via load_config" do
    Xapit.load_config("spec/fixtures/xapit.yml", "development")
    Xapit.config[:database_path].should == "development_database"
  end

  it "raises an exception when accessing the database while disabled" do
    Xapit.config[:enabled] = false
    lambda { Xapit.database }.should raise_exception(Xapit::Disabled)
  end
end
