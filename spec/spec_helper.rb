require 'rubygems'
require 'spec'
require 'active_support'
require File.dirname(__FILE__) + '/../lib/xapit.rb'

Spec::Runner.configure do |config|
  config.mock_with :rr
end
