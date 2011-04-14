require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'active_support/all'
require 'fileutils'
require 'xapit_member'

RSpec.configure do |config|
  config.mock_with :rr
  config.before(:each) do
    Xapit.setup(:database_path => File.dirname(__FILE__) + '/tmp/testdb', :template_path => File.dirname(__FILE__) + "/fixtures/blankdb")
    Xapit.remove_database
    XapitMember.delete_all
    GC.start # Seems to be necessary to speed up test suite
  end
end
