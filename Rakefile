require 'rubygems'
require 'rake'
require 'cucumber'
require 'cucumber/rake/task'

Dir["#{File.dirname(__FILE__)}/tasks/*.rb"].sort.each { |ext| load ext }

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress"
end

task :default => [:spec, :features]
