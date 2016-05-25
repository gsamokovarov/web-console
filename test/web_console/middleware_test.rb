require 'test_helper'

module WebConsole
  class MiddlewareTest < ActionDispatch::IntegrationTest
    class Application
      def initialize(options = {})
        @response_content_type = options[:response_content_type] || Mime[:html]
      end

      def call(env)
        [ status, headers, body ]
      end

      private

        def status
          500
        end

        def headers
          { 'Content-Type' => "#{@response_content_type}; charset=utf-8" }
        end

        def body
          Array(<<-HTML.strip_heredoc)
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
    end

    setup do
      Rails.stubs(:root).returns Pathname(__FILE__).parent
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('0.0.0.0/0'))

      Middleware.mount_point = ''
      @app = Middleware.new(Application.new)
    end

    test 'render console in an html application from web_console.binding' do
      Thread.current[:__web_console_binding] = binding

      get '/', params: nil

      assert_select '#console'
    end

    test 'render console in an html application from web_console.exception' do
      Thread.current[:__web_console_exception] = raise_exception

      get '/', params: nil

      assert_select 'body > #console'
    end

    test 'render error_page.js from web_console.exception' do
      Thread.current[:__web_console_exception] = raise_exception

      get '/', params: nil

      assert_select 'body > script[data-template=error_page]'
    end

    test 'render console if response format is HTML' do
      Thread.current[:__web_console_binding] = binding
      @app = Middleware.new(Application.new(response_content_type: Mime[:html]))

      get '/', params: nil

      assert_select '#console'
    end

    test 'does not render console if response format is not HTML' do
      Thread.current[:__web_console_binding] = binding
      @app = Middleware.new(Application.new(response_content_type: Mime[:json]))

      get '/', params: nil

      assert_select '#console', 0
    end

    test 'returns X-Web-Console-Session-Id as response header' do
      Thread.current[:__web_console_binding] = binding

      get '/', params: nil

      session_id = response.headers["X-Web-Console-Session-Id"]

      assert_not Session.find(session_id).nil?
    end

    test "doesn't render console in non html response" do
      Thread.current[:__web_console_binding] = binding
      @app = Middleware.new(Application.new(response_content_type: Mime[:json]))

      get '/', params: nil

      assert_select '#console', 0
    end

    test "doesn't render console from non whitelisted IP" do
      Thread.current[:__web_console_binding] = binding
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('127.0.0.1'))

      silence(:stderr) do
        get '/', params: nil, headers: { 'REMOTE_ADDR' => '1.1.1.1' }
      end

      assert_select '#console', 0
    end

    test "doesn't render console without a web_console.binding or web_console.exception" do
      get '/', params: nil

      assert_select '#console', 0
    end

    test 'can evaluate code and return it as a JSON' do
      session, line = Session.new(binding), __LINE__

      Session.stubs(:from).returns(session)

      get '/', params: nil
      put "/repl_sessions/#{session.id}", xhr: true, params: { input: '__LINE__' }

      assert_equal({ output: "=> #{line}\n" }.to_json, response.body)
    end

    test 'can switch bindings on error pages' do
      session = Session.new(exception = raise_exception)

      Session.stubs(:from).returns(session)

      get '/', params: nil
      post "/repl_sessions/#{session.id}/trace", xhr: true, params: { frame_id: 1 }

      assert_equal({ ok: true }.to_json, response.body)
    end

    test 'can be changed mount point' do
      Middleware.mount_point = '/customized/path'

      session, line = Session.new(binding), __LINE__
      put "/customized/path/repl_sessions/#{session.id}", params: { input: '__LINE__' }, xhr: true

      assert_equal({ output: "=> #{line}\n" }.to_json, response.body)
    end

    test 'unavailable sessions respond to the user with a message' do
      put '/repl_sessions/no_such_session', xhr: true, params: { input: '__LINE__' }

      assert_equal(404, response.status)
    end

    test 'unavailable sessions can occur on binding switch' do
      post "/repl_sessions/no_such_session/trace", xhr: true, params: { frame_id: 1 }

      assert_equal(404, response.status)
    end

    test "doesn't accept request for old version and return 406" do
      put "/repl_sessions/no_such_session", xhr: true, params: { input: "__LINE__" },
        headers: {"HTTP_ACCEPT" => "application/vnd.web-console.v0"}

      assert_equal(406, response.status)
    end

    test 'reraises application errors' do
      @app = proc { raise }

      assert_raises(RuntimeError) { get '/' }
    end

    private

      # Override the put and post testing helper of ActionDispatch to customize http headers
      def put(http_method, path, *args)
        update_path_args(path)
        super
      end

      def post(http_method, path, *args)
        update_path_args(path)
        super
      end

      def update_path_args(path)
        unless path[:headers]
          path.merge!(headers: { 'HTTP_ACCEPT' => Mime[:web_console_v2] })
        end
      end

      def raise_exception
        raise
      rescue => exc
        exc
      end
  end
end
