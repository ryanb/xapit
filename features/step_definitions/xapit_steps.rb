Given /^I configured the database to be saved at "([^\"]*)"$/ do |path|
  Xapit::Config.setup(:database_path => File.dirname(__FILE__) + "/../../#{path}")
end

Given /^an empty database at "([^\"]*)"$/ do |path|
  Xapit::Config.setup(:database_path => File.dirname(__FILE__) + "/../../#{path}")
  Xapit::Config.remove_database
  XapitMember.delete_all
end

Given /^(indexed )?records? named "([^\"]*)"$/ do |indexed, joined_names|
  records = joined_names.split(', ').map { |name| {:name => name} }
  create_records(records, indexed)
end

Given /^([0-9]+) (indexed )?records?$/ do |num, indexed|
  create_records([:name => "foo"]*num.to_i, indexed)
end

Given /^the following indexed records$/ do |records_table|
  create_records(records_table.hashes)
end

When /^I index the database$/ do
  Xapit.index_all
end

When /^I index the database splitting name by "([^\"]*)"$/ do |divider|
  XapitMember.xapit do |index|
    index.text(:name) { |name| name.split(divider) }
  end
  Xapit.index_all
end

When /^I query for "([^\"]*)"$/ do |query|
  @records = XapitMember.search(query)
end

When /^I query for "([^\"]*)" on Xapit$/ do |query|
  @records = Xapit.search(query)
end

When /^I query "([^\"]*)" with facets "([^\"]*)"$/ do |keywords, facets|
  @records = XapitMember.search(keywords, :facets => facets)
end

Then /^I should find records? named "([^\"]*)"$/ do |joined_names|
  @records.map(&:name).join(", ").should == joined_names
end

Then /^I should find ([0-9]+) records?$/ do |num|
  @records.should have(num.to_i).records
end

Then /^I should have ([0-9]+) records? total$/ do |num|
  @records.total_entries.should == num.to_i
end

When /^I query "([^\"]*)" matching "([^\"]*)"$/ do |field, value|
  @records = XapitMember.search("", :conditions => { field.to_sym => value })
end

When /^I query page ([0-9]+) at ([0-9]+) per page$/ do |page, per_page|
  @records = XapitMember.search("", :page => page, :per_page => per_page.to_i)
end

When /^I query facets "([^\"]*)"$/ do |facets|
  @records = XapitMember.search("", :facets => facets)
end

When /^I query "([^\"]*)" sorted by (.*?)( descending)?$/ do |keywords, sort, descending|
  @records = XapitMember.search("", :order => sort.split(', '), :descending => descending)
end

Then /^I should have the following facets$/ do |facets_table|
  result = []
  @records.facets.each do |facet|
    facet.options.each do |option|
      result << {
        "facet" => facet.name,
        "option" => option.name,
        "count" => option.count.to_s
      }
    end
  end
  result.should == facets_table.hashes # this is somewhat fragile because it depends on order of hash result
end

Then /^I should have the following applied facets$/ do |facets_table|
  result = []
  @records.applied_facet_options.each do |option|
    result << {
      "facet" => option.facet.name,
      "option" => option.name
    }
  end
  result.should == facets_table.hashes # this is somewhat fragile because it depends on order of hash result
end

Then /^I should have "([^\"]*)" as a spelling suggestion$/ do |term|
  @records.spelling_suggestion.should == term
end

