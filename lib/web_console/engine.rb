require 'ipaddr'
require 'active_support/core_ext/numeric/time'
require 'rails/engine'

require 'active_model'
require 'sprockets/rails'

module WebConsole
  class Engine < ::Rails::Engine
    isolate_namespace WebConsole

    config.web_console = ActiveSupport::OrderedOptions.new.tap do |c|
      c.automount          = false
      c.command            = nil
      c.default_mount_path = '/console'
      c.timeout            = 0.seconds
      c.term               = 'xterm-color'
      c.whitelisted_ips    = '127.0.0.1'

      c.style = ActiveSupport::OrderedOptions.new.tap do |s|
        s.colors = 'light'
        s.font   = 'large DejaVu Sans Mono, Liberation Mono, monospace'
      end
    end

    initializer "web_console.initialize_view_helpers" do
      ActiveSupport.on_load :action_view do
        include WebConsole::ViewHelpers
      end

      ActiveSupport.on_load :action_controller do
        prepend_view_path File.dirname(__FILE__) + '/../action_dispatch/templates'
      end
    end

    initializer 'web_console.add_default_route' do |app|
      # While we don't need the route in the test environment, we define it
      # there as well, so we can easily test it.
      if config.web_console.automount && (Rails.env.development? || Rails.env.test?)
        app.routes.append do
          mount WebConsole::Engine => app.config.web_console.default_mount_path
        end
      end
    end

    initializer 'web_console.process_whitelisted_ips' do
      config.web_console.tap do |c|
        # Ensure that it is an array of IPAddr instances and it is defaulted to
        # 127.0.0.1 if not precent. Only unique entries are left in the end.
        c.whitelisted_ips = Array(c.whitelisted_ips).map { |ip|
          if ip.is_a?(IPAddr)
            ip
          else
            IPAddr.new(ip.presence || '127.0.0.1')
          end
        }.uniq

        # IPAddr instances can cover whole networks, so simplify the #include?
        # check for the most common case.
        def (c.whitelisted_ips).include?(ip)
          if ip.is_a?(IPAddr)
            super
          else
            any? { |net| net.include?(ip.to_s) }
          end
        end
      end
    end

    initializer 'web_console.process_command' do
      config.web_console.tap do |c|
        # +Rails.root+ is not available while we set the default values of the
        # other options. Default it during initialization.

        # Not all people created their Rails 4 applications with the Rails 4
        # generator, so bin/rails may not be available.
        if c.command.blank?
          local_rails = Rails.root.join('bin/rails')
          c.command = "#{local_rails.executable? ? local_rails : 'rails'} console"
        end
      end
    end

    initializer 'web_console.process_colors' do
      config.web_console.style.tap do |c|
        case colors = c.colors
        when Symbol, String
          c.colors = Colors[colors] || Colors.default
        else
          c.colors = Colors.new(colors)
        end
      end
    end
  end
end
