require 'rails/engine'

module WebConsole
  class Engine < ::Rails::Engine
    isolate_namespace WebConsole

    config.web_console = ActiveSupport::OrderedOptions.new
    config.web_console.default_mount_path = '/console'

    initializer 'web_console.add_default_route' do |app|
      # While we don't need the route in the test environment, we define it
      # there as well, so we can easily test it.
      if Rails.env.development? || Rails.env.test?
        app.routes.append do
          mount WebConsole::Engine => app.config.web_console.default_mount_path
        end
      end
    end
  end
end
