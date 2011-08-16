Given /^an empty database at "([^\"]*)"$/ do |path|
  path = File.expand_path("../../../#{path}", __FILE__)
  template = File.expand_path("../../../spec/fixtures/blankdb", __FILE__)
  FileUtils.rm_rf(path) if File.exist? path
  FileUtils.cp_r(template, path)
  Xapit.config[:database_path] = path
  XapitMember.delete_all
  GC.start
end

Given /^a remote database$/ do
  $server = IO.popen("rackup spec/fixtures/xapit.ru -p 9797") if $server.nil?
  Xapit.reset_config
  Xapit.config[:server] = "http://localhost:9797"
  XapitMember.delete_all
  sleep 5
end

Given /^no stemming$/ do
  Xapit.config[:stemming] = nil
end

Given /^spelling is enabled$/ do
  Xapit.config[:spelling] = true
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

Given /^the following indexed records with "([^\"]*)" weighted by "([^\"]*)"$/ do |weight_name, weight_value, records_table|
  create_records(records_table.hashes) do |index, attribute|
    if attribute.to_s == weight_name
      index.text attribute, :weight => weight_value.to_i
    else
      index.text attribute
    end
  end
end

When /^I index the database$/ do
  XapitMember.find_each do |member|
    member.class.xapit_index_builder.add_document(member)
  end
end

When /^I index the database splitting name by "([^\"]*)"$/ do |divider|
  XapitMember.xapit do |index|
    index.text(:name) { |name| name.split(divider) }
  end
  XapitMember.find_each do |member|
    member.class.xapit_index_builder.add_document(member)
  end
end

When /^I query for "([^\"]*)"$/ do |query|
  @records = XapitMember.search(query)
end

When /^I query for "([^\"]*)" on Xapit$/ do |query|
  @records = Xapit.search(query)
end

When /^I query "([^\"]*)" with facets "([^\"]*)"$/ do |keywords, facets|
  @records = XapitMember.search(keywords).with_facets(facets)
end

Then /^I should find records? named "([^\"]*)"$/ do |joined_names|
  @records.map(&:name).join(", ").should eq(joined_names)
end

Then /^I should find ([0-9]+) records?$/ do |num|
  @records.records.size.should eq(num.to_i)
end

Then /^I should have ([0-9]+) records? total$/ do |num|
  @records.total_entries.should eq(num.to_i)
end

When /^I query "([^\"]*)" matching "([^\"]*)"$/ do |field, value|
  @records = XapitMember.search.where(field.to_sym => value)
end

When /^I query for "([^\"]*)" and "([^\"]*)" matching "([^\"]*)"$/ do |text, field, value|
  @records = XapitMember.search(text).where(field.to_sym => value)
end

When /^I query "([^\"]*)" not matching "([^\"]*)"$/ do |field, value|
  @records = XapitMember.search.not_where(field.to_sym => value)
end

When /^I query "([^\"]*)" matching "([^\"]*)" or "([^\"]*)" matching "([^\"]*)"$/ do |field1, value1, field2, value2|
  @records = XapitMember.search.where(field1.to_sym => value1).or_where(field2.to_sym => value2)
end

When /^I query for "([^\"]*)" or "([^\"]*)" matching "([^\"]*)" ordered by "([^\"]*)"$/ do |keywords, field, value, order|
  @records = XapitMember.search(keywords).order(order).or_where(field.to_sym => value)
end

When /^I query "([^\"]*)" between (\d+) and (\d+)$/ do |field, beginning, ending|
  @records = XapitMember.search.where(field.to_sym => beginning.to_i..ending.to_i)
end

When /^I query page ([0-9]+) at ([0-9]+) per page$/ do |page, per_page|
  @records = XapitMember.search.page(page).per(per_page)
end

When /^I query facets "([^\"]*)"$/ do |facets|
  @records = XapitMember.search.with_facets(facets)
end

When /^I query "([^\"]*)" sorted by (.*?)( descending)?$/ do |keywords, sort, descending|
  @records = XapitMember.search
  sort.split(', ').each do |sort|
    @records = @records.order(sort, (descending ? :desc : :asc))
  end
end

When /^I query for similar records for "([^\"]*)"$/ do |keywords|
  @records = XapitMember.search(keywords).first.search_similar
end

Then /^I should have the following facets$/ do |facets_table|
  result = []
  @records.facets.each do |facet|
    facet.options.each do |option|
      hash = {
        "facet" => facet.name,
        "option" => option.name,
        "count" => option.count.to_s
      }
      hash["param"] = option.to_param if facets_table.headers.include? "param"
      result << hash
    end
  end
  result.map(&:inspect).sort.should eq(facets_table.hashes.map(&:inspect).sort)
end

Then /^I should have the following applied facets$/ do |facets_table|
  result = []
  @records.applied_facet_options.each do |option|
    result << {
      "facet" => option.attribute.sub(/^(.)/) { |c| c.upcase }, # quick hack
      "option" => option.name
    }
  end
  result.map(&:inspect).sort.should eq(facets_table.hashes.map(&:inspect).sort)
end

Then /^I should have "([^\"]*)" as a spelling suggestion$/ do |term|
  @records.spelling_suggestion.to_s.should eq(term)
end
