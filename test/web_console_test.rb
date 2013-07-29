require 'test_helper'

class WebConsoleTest < ActiveSupport::TestCase
  test 'different default_mount_path' do
    new_uninitialized_app do |app|
      app.config.web_console.default_mount_path = '/shell'
      app.initialize!

      assert app.routes.named_routes['web_console'].path.match('/shell')
    end
  end

  test 'whitelisted ips are courced to IPAddr' do
    new_uninitialized_app do |app|
      app.config.web_console.whitelisted_ips = '127.0.0.1'
      app.initialize!

      assert_equal [ IPAddr.new('127.0.0.1') ], app.config.web_console.whitelisted_ips
    end
  end

  test 'whitelisted ips are normalized and unique IPAddr' do
    new_uninitialized_app do |app|
      app.config.web_console.whitelisted_ips = [ '127.0.0.1', '127.0.0.1', nil, '', ' ' ]
      app.initialize!

      assert_equal [ IPAddr.new('127.0.0.1') ], app.config.web_console.whitelisted_ips
    end
  end

  test 'whitelisted_ips.include? coerces to IPAddr' do
    new_uninitialized_app do |app|
      app.config.web_console.whitelisted_ips = '127.0.0.1'
      app.initialize!

      assert app.config.web_console.whitelisted_ips.include?('127.0.0.1')
    end
  end

  test 'whitelisted_ips.include? works with IPAddr' do
    new_uninitialized_app do |app|
      app.config.web_console.whitelisted_ips = '127.0.0.1'
      app.initialize!

      assert app.config.web_console.whitelisted_ips.include?(IPAddr.new('127.0.0.1'))
    end
  end

  test 'whitelist whole networks' do
    new_uninitialized_app do |app|
      app.config.web_console.whitelisted_ips = '172.16.0.0/12'
      app.initialize!

      1.upto(255).each do |n|
        assert_includes app.config.web_console.whitelisted_ips, "172.16.0.#{n}"
      end
    end
  end

  test 'whitelist multiple networks' do
    new_uninitialized_app do |app|
      app.config.web_console.whitelisted_ips = %w( 172.16.0.0/12 192.168.0.0/16 )
      app.initialize!

      1.upto(255).each do |n|
        assert_includes app.config.web_console.whitelisted_ips, "172.16.0.#{n}"
        assert_includes app.config.web_console.whitelisted_ips, "192.168.0.#{n}"
      end
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
