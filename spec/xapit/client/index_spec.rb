require "spec_helper"

describe Xapit::Client::Index do
  it "parses text attributes" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :greeting, :name
    member = XapitMember.new(:greeting => "hello world", :name => "John")
    index = Xapit::Client::Index.new(builder, member)
    index.data[:id].should == member.id
    index.data[:class].should == "XapitMember"
    index.data[:texts].should == {:greeting => {:value => "hello world"}, :name => {:value => "John"}}
  end

  it "parses text attribute with weight option" do
    builder = Xapit::Client::IndexBuilder.new
    builder.text :greeting, :weight => 3
    index = Xapit::Client::Index.new(builder, XapitMember.new(:greeting => "hello"))
    index.data[:texts].should == {:greeting => {:value => "hello", :weight => 3}}
  end
end
