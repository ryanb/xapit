require "spec_helper"
require "ostruct"

describe Xapit::Client::Index do
  it "parses text attributes" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :greeting, :name
    index = Xapit::Client::Index.new(builder, OpenStruct.new(:greeting => "hello world", :name => "John", :id => 123))
    index.data[:id].should == 123
    index.data[:class].should == "OpenStruct"
    index.data[:texts].should == {:greeting => {:value => "hello world"}, :name => {:value => "John"}}
  end

  it "parses text attribute with weight option" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :greeting, :weight => 3
    index = Xapit::Client::Index.new(builder, OpenStruct.new(:greeting => "hello"))
    index.data[:texts].should == {:greeting => {:value => "hello", :weight => 3}}
  end
end
