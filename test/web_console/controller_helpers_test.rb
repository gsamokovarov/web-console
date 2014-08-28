require 'test_helper'

module WebConsole
  class ControllerHelperTest < ActionController::TestCase
    class TestController < ActionController::Base
      def render_console_ontop_of_text
        render text: '<h1 id="greeting">Hello World</h1>'
        console
      end
    end

    tests TestController

    test "injects a console into a view" do
      get :render_console_ontop_of_text

      assert_select "#console"
    end

    test "keeps the original content" do
      get :render_console_ontop_of_text

      assert_select "#greeting", "Hello World"
    end
  end
end
