require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)
require 'web_console'

# Require pry-rails pry shell is explicitly requested.
require 'pry-rails' if ENV['PRY']

module Dummy
  class Application < Rails::Application
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
      config.web_console.pending_output_wait = 45.seconds
    end
  end
end

