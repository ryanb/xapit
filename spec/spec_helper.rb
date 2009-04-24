require 'rubygems'
require 'spec'
require 'active_support'
require 'fileutils'
require File.dirname(__FILE__) + '/../lib/xapit'
require File.dirname(__FILE__) + '/xapit_member'

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.before(:each) do
    Xapit::Config.setup(:database_path => File.dirname(__FILE__) + '/tmp/xapiandb')
    Xapit::Config.remove_database
    XapitMember.delete_all
  end
end
