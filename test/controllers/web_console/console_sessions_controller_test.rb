require 'test_helper'

module WebConsole
  class ConsoleSessionsControllerTest < ActionController::TestCase
    setup do
      # Where does .stubs lives?
      def @request.remote_ip; '127.0.0.1' end
    end

    test 'index is successful' do
      get :index, use_route: 'web_console'
      assert_response :success
    end

    test 'index creates new console session' do
      assert_difference 'ConsoleSession::INMEMORY_STORAGE.size' do
        get :index, use_route: 'web_console'
      end
    end

    test 'blocks requests from non-whitelisted ips' do
      def @request.remote_ip; '128.0.0.1' end
      get :index, use_route: 'web_console'
      assert_response :unauthorized
    end

    test 'index generated path' do
      assert_generates mount_path, {
        use_route: 'web_console',
        controller: 'console_sessions'
      }, {}, {controller: 'console_sessions'}
    end

    private

      def mount_path
        WebConsole::Engine.config.web_console.default_mount_path
      end
  end
end
