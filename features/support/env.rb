require 'bundler/setup'

Bundler.require(:default)

require File.expand_path('../../../spec/support/xapit_member', __FILE__)

Before do
  Xapit.reset_config
  Xapit.config[:spelling] = false
end

at_exit do
  $server.close if $server
end
