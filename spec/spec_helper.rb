require 'rubygems'
require 'spec'
require 'active_support'
require 'fileutils'
require File.dirname(__FILE__) + '/../lib/xapit'
require File.dirname(__FILE__) + '/xapit_member'

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.before(:each) do
    Xapit.setup(:database_path => File.dirname(__FILE__) + '/tmp/testdb', :template_path => File.dirname(__FILE__) + "/fixtures/blankdb")
    Xapit.remove_database
    XapitMember.delete_all
    GC.start # Seems to be necessary to speed up test suite
  end
end
