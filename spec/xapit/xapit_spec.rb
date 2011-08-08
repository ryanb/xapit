require "spec_helper"

describe Xapit do
  it "loads a simple configuration file via load_config" do
    Xapit.load_config("spec/fixtures/xapit.yml", "development")
    Xapit.config[:database_path].should == "development_database"
  end
end
