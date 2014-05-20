require "json"
require "ipaddr"
require "set"

module WebConsole
  class Middleware
    ALLOWED_IPS = Set.new

    def self.allow_ip!(addr)
      ALLOWED_IPS << IPAddr.new(addr)
    end

    allow_ip! "127.0.0.0/8"
    allow_ip! "::1/128" rescue nil # windows ruby doesn't have ipv6 support

    def initialize(app, handler = ErrorPage)
      @app      = app
      @handler  = handler
    end

    def call(env)
      if allow_ip? env
        web_console_call env
      else
        @app.call env
      end
    end

  private
    def allow_ip?(env)
      # REMOTE_ADDR is not in the rack spec, so some application servers do
      # not provide it.
      return true unless env["REMOTE_ADDR"] and !env["REMOTE_ADDR"].strip.empty?
      ip = IPAddr.new env["REMOTE_ADDR"].split("%").first
      ALLOWED_IPS.any? { |subnet| subnet.include? ip }
    end

    def web_console_call(env)
      @app.call env
    rescue Exception => ex
      @error_page = @handler.new ex, env
      show_error_page(env, ex)
    end

    def show_error_page(env, exception=nil)
      type, content = if @error_page
        if text?(env)
          [ 'plain', @error_page.render('text') ]
        else
          [ 'html', @error_page.render ]
        end
      else
        [ 'html', no_errors_page ]
      end

      status_code = 500
      if defined? ActionDispatch::ExceptionWrapper
        status_code = ActionDispatch::ExceptionWrapper.new(env, exception).status_code
      end

      [status_code, { "Content-Type" => "text/#{type}; charset=utf-8" }, [content]]
    end

    def text?(env)
      env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest" ||
      !env["HTTP_ACCEPT"].to_s.include?('html')
    end

    def no_errors_page
      "<h1>No errors</h1><p>No errors have been recorded yet.</p><hr>"
    end
  end
end
