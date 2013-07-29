require 'test_helper'

module WebConsole
  class ConsoleSessionsControllerTest < ActionController::TestCase
    setup do
      # Where does #stubs lives?
      def (@controller.request).remote_ip
        '127.0.0.1'
      end
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

    test 'update updates new console session' do
      get :index, use_route: 'web_console'
      assert_not_nil console_session = assigns(:console_session)

      put :update, id: console_session.id, input: 42, use_route: 'web_console'
      assert_match %r{42}, console_session.output
    end

    test 'update failes when session is no longer available' do
      get :index, use_route: 'web_console'
      assert_not_nil console_session = assigns(:console_session)

      ConsoleSession::INMEMORY_STORAGE.delete(console_session.id)
      put :update, id: console_session.id, input: 42, use_route: 'web_console'
      assert_response :gone
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
