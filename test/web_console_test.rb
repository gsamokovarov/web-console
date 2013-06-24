require 'rails'
require 'action_controller/railtie'
require 'active_support/dependencies'
require 'tzinfo'
require 'test_helper'

class WebConsoleTest < ActiveSupport::TestCase
  @@default_mount_path = nil
  class << self
    private

      def default_mount_path(path)
        @@default_mount_path = path
      end
  end

  ROOT = File.expand_path('../dummy', __FILE__)
  FIXTURES_PATH = File.expand_path('../fixtures', __FILE__)

  def setup
    FileUtils.mkdir_p ROOT
    Dir.chdir ROOT

    @old_app = Rails.application
    Rails.application = nil

    @app = Class.new(Rails::Application)
    @app.config.eager_load = false
    @app.config.time_zone = 'UTC'
    @app.config.middleware ||= Rails::Configuration::MiddlewareStackProxy.new
    @app.config.active_support.deprecation = :notify

    if @@default_mount_path
      @app.config.web_console.default_mount_path = @@default_mount_path
    end

    @app.initialize!
  end

  def teardown
    Rails.application = @old_app
  end

  default_mount_path '/shell'
  test 'different default_mount_path' do
    @app.config.web_console.default_mount_path
  end
end
