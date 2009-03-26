Given /^I configured the database to be saved at "([^\"]*)"$/ do |path|
  Xapit::Config.setup(:database_path => File.dirname(__FILE__) + "/../../#{path}")
end

Given /^I have a class to be indexed$/ do
  XapitMember.xapit do |index|
    index.text :name
  end
end

Given /^I have ([0-9]+) records?$/ do |num|
  num.to_i.times do
    XapitMember.new(:name => "foo")
  end
end

When /^I index the database$/ do
  Xapit::IndexBlueprint.index_all
end