require 'test_helper'

class WebConsoleTest < ActiveSupport::TestCase
  test 'different default_mount_path' do
    new_uninitialized_app do |app|
      app.config.web_console.default_mount_path = '/shell'
      app.initialize!

      assert app.routes.named_routes['web_console'].path.match('/shell')
    end
  end

  private

    def new_uninitialized_app(root = File.expand_path('../dummy', __FILE__))
      FileUtils.mkdir_p root
      Dir.chdir root

      old_app = Rails.application
      Rails.application = nil

      app = Class.new(Rails::Application)
      app.config.eager_load = false
      app.config.time_zone = 'UTC'
      app.config.middleware ||= Rails::Configuration::MiddlewareStackProxy.new
      app.config.active_support.deprecation = :notify

      yield app
    ensure
      Rails.application = old_app
    end
end
