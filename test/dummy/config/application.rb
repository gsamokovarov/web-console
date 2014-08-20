require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)
require 'web_console'

# Require pry-rails if the pry shell is explicitly requested.
require 'pry-rails' if ENV['PRY']

module Dummy
  class Application < Rails::Application
    # Automatically mount the console to tests the terminal side as well.
    config.web_console.automount = true

    # When the Dummy application is ran in a docker container, the local
    # computer address is in the 172.16.0.0/12 range. Have it whitelisted.
    config.web_console.whitelisted_ips = %w( 127.0.0.1 172.16.0.0/12 )

    if ENV['LONG_POLLING']
      # You have to explicitly enable the concurrency, as in development mode,
      # the falsy config.cache_classes implies no concurrency support.
      #
      # The concurrency is enabled by removing the Rack::Lock middleware, which
      # wraps each request in a mutex, effectively making the request handling
      # synchronous.
      config.allow_concurrency = true

      # For long-polling 45 seconds timeout seems reasonable.
      config.web_console.timeout = 45.seconds
    end

    config.web_console.style.colors =
      if ENV['SOLARIZED_LIGHT']
        'solarized_light'
      elsif ENV['SOLARIZED_DARK']
        'solarized_dark'
      elsif ENV['TANGO']
        'tango'
      elsif ENV['XTERM']
        'xterm'
      elsif ENV['MONOKAI']
        'monokai'
      else
        'light'
      end
  end
end
