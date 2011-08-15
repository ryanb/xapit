if ENV["MODEL_ADAPTER"].nil? || ENV["MODEL_ADAPTER"] == "active_record"
  require "spec_helper"

  RSpec.configure do |config|
    config.extend WithModel
  end

  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

  describe Xapit::Client::ActiveRecordAdapter do
    with_model :article do
      table do |t|
        t.string "name"
      end
    end

    before(:each) do
      load_xapit_database
      Article.xapit { text :name }
    end

    it "is only for active record classes" do
      Xapit::Client::ActiveRecordAdapter.should_not be_for_class(Object)
      Xapit::Client::ActiveRecordAdapter.should be_for_class(Article)
      Xapit::Client::AbstractModelAdapter.adapter_class(Article).should == Xapit::Client::ActiveRecordAdapter
    end

    it "creates document when saved" do
      article = Article.create!(:name => "Foo Bar")
      Article.search("Foo Bar").records.should eq([article])
    end

    it "deletes a document when removed" do
      article = Article.create!(:name => "Foo Bar")
      article.destroy
      Article.search("Foo Bar").records.should eq([])
    end

    it "update a document when changed" do
      article = Article.create!(:name => "Foo Bar")
      article.update_attribute(:name, "Hello World")
      Article.search("Foo Bar").records.should eq([])
      Article.search("Hello World").records.should eq([article])
    end

    it "does not index records while disabled" do
      Xapit.config[:enabled] = false
      Article.create!(:name => "Foo Bar")
      Xapit.config[:enabled] = true
      Article.search("Foo Bar").records.should eq([])
    end

    it "reindexes all records for a model" do
      Xapit.config[:enabled] = false
      article = Article.create!(:name => "Foo Bar")
      Xapit.config[:enabled] = true
      Xapit.index(Article)
      Article.search("Foo Bar").records.should eq([article])
    end
  end
end
