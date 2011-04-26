require 'rubygems'
require 'rake'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

desc "Run Cucumber"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w[--format progress]
end

task :default => [:spec, :cucumber]
