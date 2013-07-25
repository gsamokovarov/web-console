require 'test_helper'

module WebConsole
  class ConsoleSessionsControllerTest < ActionController::TestCase
    test 'index is successful' do
      get :index, use_route: 'web_console'
      assert_response :success
    end

    test 'index generated path' do
      assert_generates '/console', {
        use_route: 'web_console',
        controller: 'console_sessions'
      }, {}, {controller: 'console_sessions'}
    end
  end
end
