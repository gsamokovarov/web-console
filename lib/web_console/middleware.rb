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
      # Only show the error page when the IP is allowed and the request is not XHR
      if allow_ip?(env) && ! xhr?(env)
        web_console_call(env)
      else
        @app.call(env)
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
        [ 'html', @error_page.render ]
      else
        [ 'html', no_errors_page ]
      end

      status_code = 500
      if defined? ActionDispatch::ExceptionWrapper
        status_code = ActionDispatch::ExceptionWrapper.new(env, exception).status_code
      end

      [status_code, { "Content-Type" => "text/#{type}; charset=utf-8" }, [content]]
    end

    def xhr?(env)
      env['HTTP_X_REQUESTED_WITH'] =~ /XMLHttpRequest/i
    end

    def no_errors_page
      "<h1>No errors</h1><p>No errors have been recorded yet.</p><hr>"
    end
  end
end
