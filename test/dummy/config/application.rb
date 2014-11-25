require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)
require 'web_console'

# Require pry-rails if the pry shell is explicitly requested.
require 'pry-rails' if ENV['PRY']

module Dummy
  class Application < Rails::Application
    # When the Dummy application is ran in a docker container, the local
    # computer address is in the 172.16.0.0/12 range. Have it whitelisted.
    config.web_console.whitelisted_ips = %w( 127.0.0.1 172.16.0.0/12 )

    config.active_support.test_order = :random
  end
end
