require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('xapit', '0.2.5') do |p|
  p.summary        = "Ruby library for interacting with Xapian, a full text search engine."
  p.description    = "Ruby library for interacting with Xapian, a full text search engine."
  p.url            = "http://github.com/ryanb/xapit"
  p.author         = 'Ryan Bates'
  p.email          = "ryan (at) railscasts (dot) com"
  p.ignore_pattern = ["tmp/**/*", "spec/tmp/**/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rb"].sort.each { |ext| load ext }
