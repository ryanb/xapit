require "rubygems"
require "xapit"

Xapit.load_config(File.expand_path('../config/xapit.yml', __FILE__), "production")

run Xapit::Server::App.new
