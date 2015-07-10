require 'rails/railtie'

module WebConsole
  class Railtie < ::Rails::Railtie
    config.web_console = ActiveSupport::OrderedOptions.new
    config.web_console.whitelisted_ips = %w( 127.0.0.1 ::1 )

    # See rails/web-console#150 and rails/rails#20319. Revert when Ruby on
    # Rails 4.2.4 is released.
    config.web_console.development_only = false

    initializer 'web_console.initialize' do
      require 'web_console/extensions'

      ActiveSupport.on_load(:action_view) do
        ActionView::Base.send(:include, Helper)
      end

      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, Helper)
      end
    end

    initializer 'web_console.development_only' do
      unless (config.web_console.development_only == false) || Rails.env.development?
        abort <<-END.strip_heredoc
          Web Console is activated in the #{Rails.env} environment, which is
          usually a mistake. To ensure it's only activated in development
          mode, move it to the development group of your Gemfile:

              gem 'web-console', group: :development

          If you still want to run it the #{Rails.env} environment (and know
          what you are doing), put this in your Rails application
          configuration:

              config.web_console.development_only = false
        END
      end
    end

    initializer 'web_console.insert_middleware' do |app|
      app.middleware.insert_before ActionDispatch::DebugExceptions, Middleware
    end

    initializer 'web_console.template_paths' do
      if template_paths = config.web_console.template_paths
        Template.template_paths.unshift(*Array(template_paths))
      end
    end

    initializer 'web_console.whitelisted_ips' do
      if whitelisted_ips = config.web_console.whitelisted_ips
        Request.whitelisted_ips = Whitelist.new(whitelisted_ips)
      end
    end

    initializer 'web_console.whiny_requests' do
      if config.web_console.key?(:whiny_requests)
        Middleware.whiny_requests = config.web_console.whiny_requests
      end
    end

    # Leave this undocumented so we treat such content type misses as bugs,
    # while still being able to help the affected users in the meantime.
    initializer 'web_console.acceptable_content_types' do
      if acceptable_content_types = config.web_console.acceptable_content_types
        Request.acceptable_content_types.concat(Array(acceptable_content_types))
      end
    end
  end
end
