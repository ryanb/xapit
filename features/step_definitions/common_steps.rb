Given /^no file exists at "([^\"]*)"$/ do |path|
  FileUtils.rm_rf(File.dirname(__FILE__) + "/../../#{path}") if File.exist? path
end

Then /^I should find a directory at "([^\"]*)"$/ do |path|
  File.exist?(File.dirname(__FILE__) + "/../../#{path}").should be_true
end
