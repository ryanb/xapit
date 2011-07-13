require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require "support/spec_macros"
require "support/xapit_member"

RSpec.configure do |config|
  config.include SpecMacros
  config.before(:each) do
    Xapit.reset_config
    XapitMember.delete_all
  end
end
