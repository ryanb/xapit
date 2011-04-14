require 'rubygems'
require 'rake'
# require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

require File.expand_path('../lib/xapit/rake_tasks', __FILE__)

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

desc "Run features"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w[--format progress]
end

task :default => [:spec, :cucumber]
