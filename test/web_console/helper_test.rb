require 'test_helper'

module WebConsole
  class HelperTest < ActionDispatch::IntegrationTest
    class Application
      include Helper

      def call(env)
        @env = env

        console

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

      private

        def request
          Request.new(@env)
        end
    end

    setup do
      @app = Middleware.new(Application.new)
    end

    test 'renders a console into a view' do
      get '/', nil, 'CONTENT_TYPE' => 'text/html'

      assert_select '#console'
    end

    test "doesn't hijack current view" do
      get '/', nil, 'CONTENT_TYPE' => 'text/html'

      assert_select '#hello-world'
      assert_select '#console'
    end
  end
end
