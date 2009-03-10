require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/../lib/xapit.rb'

Spec::Runner.configure do |config|
  config.mock_with :rr
end
