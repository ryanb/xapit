Then /^I should find a directory at "([^\"]*)"$/ do |path|
  File.exist?(File.dirname(__FILE__) + "/../../#{path}").should be_true
end
