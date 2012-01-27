require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require "support/spec_macros"
require "support/xapit_member"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.include SpecMacros
  config.before(:each) do
    Xapit.reset_config
    XapitMember.delete_all
  end
end
