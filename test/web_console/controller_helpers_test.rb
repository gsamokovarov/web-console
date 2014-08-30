require 'test_helper'

module WebConsole
  class ControllerHelperTest < ActionController::TestCase
    class TestController < ActionController::Base
      def render_console_ontop_of_text
        render text: '<h1 id="greeting">Hello World</h1>'
        console
      end

      def doesnt_render_console_on_non_html_requests
        render json: {}
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

    test "doesn't inject in non HTML views" do
      get :doesnt_render_console_on_non_html_requests

      assert_no_match %r{#console}, @response.body
    end
  end
end
