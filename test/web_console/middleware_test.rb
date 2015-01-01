require 'test_helper'

module WebConsole
  class MiddlewareTest < ActionDispatch::IntegrationTest
    class Application
      def call(env)
        Rack::Response.new(<<-HTML.strip_heredoc).finish
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
      WebConsole.config.stubs(:whitelisted_ips).returns(IPAddr.new('0.0.0.0/0'))

      @app = Middleware.new(Application.new)
    end

    test 'render console in an html application from web_console.binding' do
      get '/', nil, 'CONTENT_TYPE' => 'text/html', 'web_console.binding' => binding

      assert_select '#console'
    end

    test 'render console in an html application from web_console.exception' do
      get '/', nil, 'CONTENT_TYPE' => 'text/html', 'web_console.binding' => binding

      assert_select '#console'
    end

    test 'prioritizes web_console.exception over web_console.binding' do
      exception = raise_exception

      REPLSession.expects(:create).with(binding: exception.bindings.first, binding_stack: exception.bindings)

      get '/', nil, 'CONTENT_TYPE' => 'text/html', 'web_console.binding' => binding, 'web_console.exception' => exception
    end

    test 'render console in an html application with non text/html' do
      get '/', nil, 'CONTENT_TYPE' => 'application/xhtml+xml', 'web_console.binding' => binding

      assert_select '#console'
    end

    test "doesn't render console in non html application" do
      get '/', nil, 'CONTENT_TYPE' => 'application/json', 'web-console.binding' => binding

      assert_select '#console', 0
    end

    test "doesn't render console from non whitelisted IP" do
      WebConsole.config.stubs(:whitelisted_ips).returns(IPAddr.new('127.0.0.1'))

      get '/', nil, 'CONTENT_TYPE' => 'text/html', 'REMOTE_ADDR' => '1.1.1.1', 'web-console.binding' => binding

      assert_select '#console', 0
    end

    test "doesn't render console without a web_console.binding or web_console.exception" do
      get '/', nil, 'CONTENT_TYPE' => 'text/html'

      assert_select '#console', 0
    end

    private

      def raise_exception
        raise
      rescue => exc
        exc
      end
  end
end
