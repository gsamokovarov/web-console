require 'test_helper'

module WebConsole
  class ConsoleControllerTest < ActionController::TestCase
    test 'index' do
      get :index, use_route: 'console'
      assert_response :success
    end
  end
end
