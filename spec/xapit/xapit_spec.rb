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

  it "serialize_value converts time and numbers properly" do
    time = 2.days.ago
    Xapit.serialize_value(time).should eq(Xapian.sortable_serialise(time.to_i))
    Xapit.serialize_value(time.as_json).should eq(Xapian.sortable_serialise(time.to_i))
    Xapit.serialize_value(123).should eq(Xapian.sortable_serialise(123))
    Xapit.serialize_value("123").should eq(Xapian.sortable_serialise(123))
    Xapit.serialize_value("1234-56-78foo").should eq("1234-56-78foo")
  end

  it "uses a read-only database" do
    Xapit.config[:read_only] = true
    Xapit.database.should be_kind_of(Xapit::Server::ReadOnlyDatabase)
  end

  it "imports data from the changes file" do
    path = File.expand_path("../../tmp/xapitdb", __FILE__)
    Xapit.config[:database_path] = path
    File.open("#{path}_changes", "w") { |f| f.puts('{"action":"update_document", "data":{"foo": "bar"}}') }
    Xapit.stub(:database).and_return(stub)
    Xapit.database.should_receive(:update_document).with(:foo => "bar")
    Xapit.import_changes
  end
end
