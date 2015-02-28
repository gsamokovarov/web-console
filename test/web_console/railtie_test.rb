require 'test_helper'

module WebConsole
  class RailtieTest < ActiveSupport::TestCase
    test 'config.whitelisted_ips sets whitelisted networks' do
      new_uninitialized_app do |app|
        app.config.web_console.whitelisted_ips = %w( 172.16.0.0/12 192.168.0.0/16 )
        app.initialize!

        1.upto(255).each do |n|
          assert_includes Request.whitelisted_ips, "172.16.0.#{n}"
          assert_includes Request.whitelisted_ips, "192.168.0.#{n}"
        end
      end
    end

    test 'config.whitelisted_ips always includes localhost' do
      new_uninitialized_app do |app|
        app.config.web_console.whitelisted_ips = '8.8.8.8'
        app.initialize!

        assert_includes Request.whitelisted_ips, '127.0.0.1'
        assert_includes Request.whitelisted_ips, '::1'
        assert_includes Request.whitelisted_ips, '8.8.8.8'
      end
    end

    test 'config.template_paths prepend paths if it exists' do
      new_uninitialized_app do |app|
        dirname = File.expand_path('..', __FILE__)

        app.config.web_console.template_paths = dirname
        app.initialize!

        assert_equal dirname, Template.template_paths.first
      end
    end

    test 'config.whiny_request removes extra logging' do
      new_uninitialized_app do |app|
        app.config.web_console.whiny_requests = false
        app.initialize!

        assert_not Middleware.whiny_requests
      end
    end

    test 'config.acceptable_content_types adds extra content types' do
      preserving_acceptable_content_type do
        new_uninitialized_app do |app|
          app.config.web_console.acceptable_content_types = [Mime::ALL]
          app.initialize!

          assert_includes Request.acceptable_content_types, Mime::ALL
        end
      end
    end

    private

      def new_uninitialized_app(root = File.expand_path('../../dummy', __FILE__))
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

      def preserving_acceptable_content_type
        acceptable_content_types = Request.acceptable_content_types.dup
        yield
      ensure
        Request.acceptable_content_types = acceptable_content_types
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
