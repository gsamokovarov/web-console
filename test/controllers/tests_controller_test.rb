require 'test_helper'

class TestsControllerTest < ActionController::TestCase
  tests TestsController

  setup do
    request.stubs(:remote_ip).returns('127.0.0.1')
  end

  test "injects a console into a view" do
    get :render_console_ontop_of_text

    assert_select "#console"
  end

  test "renders console only once" do
    get :renders_console_only_once

    assert_select "#console", 1
  end

  test "keeps the original content" do
    get :render_console_ontop_of_text

    assert_select "#greeting", "Hello World"
  end

  test "doesn't inject in non HTML views" do
    get :doesnt_render_console_on_non_html_requests

    assert_no_match %r{#console}, @response.body
  end

  test "doesn't inject on requests from non whitelisted IPs" do
    request.stubs(:remote_ip).returns('192.168.0.100')

    get :render_console_ontop_of_text

    assert_select "#console", 0
  end
end
