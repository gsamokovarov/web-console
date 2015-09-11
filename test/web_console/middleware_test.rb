require 'test_helper'

module WebConsole
  class MiddlewareTest < ActionDispatch::IntegrationTest
    class Application
      def initialize(options = {})
        @response_content_type = options[:response_content_type] || Mime::HTML
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
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('0.0.0.0/0'))

      Middleware.mount_point = ''
      @app = Middleware.new(Application.new)
    end

    test 'render console in an html application from web_console.binding' do
      get '/', params: nil, headers: { 'web_console.binding' => binding }

      assert_select '#console'
    end

    test 'render console in an html application from web_console.exception' do
      get '/', params: nil, headers: { 'web_console.exception' => raise_exception }

      assert_select 'body > #console'
    end

    test 'render console if response format is HTML' do
      @app = Middleware.new(Application.new(response_content_type: Mime::HTML))
      get '/', params: nil, headers: { 'web_console.binding' => binding }

      assert_select '#console'
    end

    test 'does not render console if response format is not HTML' do
      @app = Middleware.new(Application.new(response_content_type: Mime::JSON))
      get '/', params: nil, headers: { 'web_console.binding' => binding }

      assert_select '#console', 0
    end

    test 'returns X-Web-Console-Session-Id as response header' do
      get '/', params: nil, headers: { 'web_console.binding' => binding }

      session_id = response.headers["X-Web-Console-Session-Id"]

      assert_not Session.find(session_id).nil?
    end

    test 'prioritizes web_console.exception over web_console.binding' do
      exception = raise_exception

      Session.expects(:from_exception).with(exception)

      get '/', params: nil, headers: { 'web_console.binding' => binding, 'web_console.exception' => exception }
    end

    test "doesn't render console in non html response" do
      @app = Middleware.new(Application.new(response_content_type: Mime::JSON))
      get '/', params: nil, headers: { 'web_console.binding' => binding }

      assert_select '#console', 0
    end

    test "doesn't render console from non whitelisted IP" do
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('127.0.0.1'))

      silence(:stderr) do
        get '/', params: nil, headers: { 'REMOTE_ADDR' => '1.1.1.1', 'web_console.binding' => binding }
      end

      assert_select '#console', 0
    end

    test "doesn't render console without a web_console.binding or web_console.exception" do
      get '/', params: nil

      assert_select '#console', 0
    end

    test 'can evaluate code and return it as a JSON' do
      session, line = Session.new(binding), __LINE__

      Session.stubs(:from_binding).returns(session)

      get '/', params: nil, headers: { 'web-console.binding' => binding }
      put "/repl_sessions/#{session.id}", xhr: true, params: { input: '__LINE__' }

      assert_equal({ output: "=> #{line}\n" }.to_json, response.body)
    end

    test 'can switch bindings on error pages' do
      session = Session.new(exception = raise_exception)

      Session.stubs(:from_exception).returns(session)

      get '/', params: nil, headers: { 'web-console.exception' => exception }
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

    test "doesn't accept request for old version and reutrn 406" do
      put "/repl_sessions/no_such_session", xhr: true, params: { input: "__LINE__" },
        headers: {"HTTP_ACCEPT" => "application/vnd.web-console.v0"}

      assert_equal(406, response.status)
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
          path.merge!(headers: { 'HTTP_ACCEPT' => Mime::WEB_CONSOLE_V2 })
        end
      end

      def raise_exception
        raise
      rescue => exc
        exc
      end
  end
end
