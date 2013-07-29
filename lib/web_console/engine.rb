require 'ipaddr'
require 'rails/engine'
require 'jquery-rails'

module WebConsole
  class Engine < ::Rails::Engine
    isolate_namespace WebConsole

    config.web_console = ActiveSupport::OrderedOptions.new
    config.web_console.default_mount_path = '/console'
    config.web_console.whitelisted_ips = '127.0.0.1'

    initializer 'web_console.add_default_route' do |app|
      # While we don't need the route in the test environment, we define it
      # there as well, so we can easily test it.
      if Rails.env.development? || Rails.env.test?
        app.routes.append do
          mount WebConsole::Engine => app.config.web_console.default_mount_path
        end
      end
    end

    initializer 'web_console.process_whitelisted_ips' do
      # Ensure that it is an array of IPAddr instances and it is defaulted to
      # 127.0.0.1 if nil.
      config.web_console.whitelisted_ips = Array(config.web_console.whitelisted_ips)
      config.web_console.whitelisted_ips.uniq!.map! do |ip|
        ip.is_a?(IPAddr) ? ip : IPAddr.new(ip || '127.0.0.1')
      end

      # IPAddr instances can cover whole networks, so simplify the #include?
      # check for the most common case.
      def (config.web_console.whitelisted_ips).include?(ip)
        if ip.is_a?(IPAddr)
          super
        else
          any? { |net| net.include?(ip.to_s) }
        end
      end
    end
  end
end
