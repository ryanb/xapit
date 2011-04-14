require 'rubygems'
require 'rake'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

require File.expand_path('../lib/xapit/rake_tasks', __FILE__)

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

desc "Run features"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress"
end

task :default => [:spec, :features]
