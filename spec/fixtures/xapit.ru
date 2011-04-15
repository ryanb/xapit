require "rubygems"

# Add lib directory so we can include xapit, this isn't necessary when a gem is available
root = File.expand_path('../../..', __FILE__)
$:.unshift "#{root}/lib"
require "xapit"

run Xapit.server(:database_path => "#{root}/tmp/testdb", :template_path => "#{root}/fixtures/blankdb")
