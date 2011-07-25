require 'bundler/setup'

Bundler.require(:default)

require File.expand_path('../../../spec/support/xapit_member', __FILE__)

at_exit do
  $server.close if $server
end
