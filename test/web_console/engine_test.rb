require 'test_helper'

module WebConsole
  class EngineTest < ActiveSupport::TestCase
    test 'config.template_paths prepend paths if it exists' do
      new_uninitialized_app do |app|
        dirname = File.expand_path('..', __FILE__)

        app.config.web_console.template_paths = dirname
        app.initialize!

        assert_equal dirname, WebConsole::Template.template_paths.first
      end
    end

    private

      def new_uninitialized_app(root = File.expand_path('../../dummy', __FILE__))
        skip if Rails::VERSION::MAJOR == 3

        old_app = Rails.application

        FileUtils.mkdir_p(root)
        Dir.chdir(root) do
          Rails.application = nil

          app = Class.new(Rails::Application)
          app.config.eager_load = false
          app.config.time_zone = 'UTC'
          app.config.middleware ||= Rails::Configuration::MiddlewareStackProxy.new
          app.config.active_support.deprecation = :notify

          yield app
        end
      ensure
        Rails.application = old_app
      end

      def teardown_fixtures(*)
        super
      rescue
        # This is nasty hack to prevent a connection to the database in JRuby's
        # activerecord-jdbcsqlite3-adapter. We don't really require a database
        # connection, for the tests to run.
        #
        # The sad thing is that I couldn't figure out why does it only happens
        # on activerecord-jdbcsqlite3-adapter and how to actually prevent it,
        # rather than work-around it.
      end
  end
end
