require "rubygems"

# Add lib directory so we can include xapit, this isn't necessary when a gem is available
root = File.expand_path('../../..', __FILE__)
$:.unshift "#{root}/lib"
require "xapit"


FileUtils.rm_rf("#{root}/tmp/testdb") # quick hack to start with a fresh database every time
Xapit.config[:database_path] = "#{root}/tmp/testdb"
Xapit.config[:template_path] = "#{root}/spec/fixtures/blankdb"

run Xapit::Server::App.new
