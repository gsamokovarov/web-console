require 'test_helper'

module WebConsole
  class ConsoleSessionsControllerTest < ActionController::TestCase
    setup do
      @request.stubs(:remote_ip).returns('127.0.0.1')
    end

    test 'index is successful' do
      get :index, use_route: 'web_console'
      assert_response :success
    end

    test 'GET index creates new console session' do
      assert_difference 'ConsoleSession::INMEMORY_STORAGE.size' do
        get :index, use_route: 'web_console'
      end
    end

    test 'PUT inputs sends input to the REPL' do
      get :index, use_route: 'web_console'

      assert_not_nil console_session = assigns(:console_session)
      console_session.expects(:send_input)

      put :input, id: console_session.pid, use_route: 'web_console'
    end

    test 'GET pending_output gives the REPL pending output' do
      get :index, use_route: 'web_console'

      assert_not_nil console_session = assigns(:console_session)
      console_session.expects(:pending_output)

      get :pending_output, id: console_session.pid, use_route: 'web_console'
    end

    test 'blocks requests from non-whitelisted ips' do
      @request.stubs(:remote_ip).returns('128.0.0.1')
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
