require 'rubygems'
require 'rake'
require 'cucumber'
require 'cucumber/rake/task'
require 'spec/rake/spectask'

Dir["#{File.dirname(__FILE__)}/tasks/*.rb"].sort.each { |ext| load ext }

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = Rake::FileList["spec/**/*_spec.rb"]
end

desc "Run features"
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress"
end

task :default => [:spec, :features]
