require 'rails/railtie'

module WebConsole
  class Railtie < ::Rails::Railtie
    config.web_console = ActiveSupport::OrderedOptions.new
    config.web_console.whitelisted_ips = %w( 127.0.0.1 ::1 )

    initializer 'web_console.initialize' do
      ActionDispatch::DebugExceptions.class_eval do
        def render_exception_with_web_console(env, exception)
          render_exception_without_web_console(env, exception).tap do
            wrapper = ActionDispatch::ExceptionWrapper.new(env, exception)

            # Get the original exception if ExceptionWrapper decides to follow it.
            env['web_console.exception'] = wrapper.exception
          end
        end

        alias_method_chain :render_exception, :web_console
      end

      ActiveSupport.on_load(:action_view) do
        ActionView::Base.send(:include, Helper)
      end

      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send(:include, Helper)
      end
    end

    initializer 'web_console.insert_middleware' do |app|
      app.middleware.insert_before ActionDispatch::DebugExceptions, Middleware
    end

    initializer 'web_console.templates_path' do
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
