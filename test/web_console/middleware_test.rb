require 'test_helper'

module WebConsole
  class MiddlewareTest < ActionDispatch::IntegrationTest
    class Application
      def initialize(options = {})
        @response_content_type = options[:response_content_type] || Mime::HTML
      end

      def call(env)
        Rack::Response.new(<<-HTML.strip_heredoc, status, headers).finish
          <html>
            <head>
              <title>Hello world</title>
            </head>
            <body>
              <p id="hello-world">Hello world</p>
            </body>
          </html>
        HTML
      end

      private

        def status
          500
        end

        def headers
          { 'Content-Type' => "#{@response_content_type}; charset=utf-8" }
        end
    end

    setup do
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('0.0.0.0/0'))

      Middleware.mount_point = ''
      @app = Middleware.new(Application.new)
    end

    test 'render console in an html application from web_console.binding' do
      get '/', nil, 'web_console.binding' => binding

      assert_select '#console'
    end

    test 'render console in an html application from web_console.exception' do
      get '/', nil, 'web_console.exception' => raise_exception

      assert_select '#console'
    end

    test 'returns X-Web-Console-Session-Id as response header' do
      get '/', nil, 'web_console.binding' => binding

      session_id = response.headers["X-Web-Console-Session-Id"]

      assert_not Session.find(session_id).nil?
    end

    test 'prioritizes web_console.exception over web_console.binding' do
      exception = raise_exception

      Session.expects(:from_exception).with(exception)

      get '/', nil, 'web_console.binding' => binding, 'web_console.exception' => exception
    end

    test "doesn't render console in non html response" do
      @app = Middleware.new(Application.new(response_content_type: Mime::JSON))
      get '/', nil, 'web_console.binding' => binding

      assert_select '#console', 0
    end

    test "doesn't render console from non whitelisted IP" do
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('127.0.0.1'))

      silence(:stderr) do
        get '/', nil, 'REMOTE_ADDR' => '1.1.1.1', 'web_console.binding' => binding
      end

      assert_select '#console', 0
    end

    test "doesn't render console without a web_console.binding or web_console.exception" do
      get '/', nil

      assert_select '#console', 0
    end

    test 'can evaluate code and return it as a JSON' do
      session, line = Session.new(binding), __LINE__

      Session.stubs(:from_binding).returns(session)

      get '/', nil, 'web-console.binding' => binding
      xhr :put, "/repl_sessions/#{session.id}", { input: '__LINE__' }

      assert_equal({ output: "=> #{line}\n" }.to_json, response.body)
    end

    test 'can switch bindings on error pages' do
      session = Session.new(exception = raise_exception)

      Session.stubs(:from_exception).returns(session)

      get '/', nil, 'web-console.exception' => exception
      xhr :post, "/repl_sessions/#{session.id}/trace", { frame_id: 1 }

      assert_equal({ ok: true }.to_json, response.body)
    end

    test 'can be changed mount point' do
      Middleware.mount_point = '/customized/path'

      session, line = Session.new(binding), __LINE__
      xhr :put, "/customized/path/repl_sessions/#{session.id}", { input: '__LINE__' }

      assert_equal({ output: "=> #{line}\n" }.to_json, response.body)
    end

    test 'unavailable sessions respond to the user with a message' do
      xhr :put, '/repl_sessions/no_such_session', { input: '__LINE__' }

      assert_equal(404, response.status)
    end

    test 'unavailable sessions can occur on binding switch' do
      xhr :post, "/repl_sessions/no_such_session/trace", { frame_id: 1 }

      assert_equal(404, response.status)
    end

    test "doesn't accept request for old version and reutrn 406" do
      xhr :put, "/repl_sessions/no_such_session", { input: "__LINE__" },
        {"HTTP_ACCEPT" => "application/vnd.web-console.v0"}

      assert_equal(406, response.status)
    end

    private

      # Override the xhr testing helper of ActionDispatch to customize http headers
      def xhr(*args)
        args[3] ||= {}
        args[3]['HTTP_ACCEPT'] ||= "#{Mime::WEB_CONSOLE_V2}"
        super
      end

      def raise_exception
        raise
      rescue => exc
        exc
      end
  end
end
