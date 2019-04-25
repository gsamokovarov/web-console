# frozen_string_literal: true

require "test_helper"

module WebConsole
  class InterceptorTest < ActionDispatch::IntegrationTest
    test "follows ActionView::Template::Error original error in Thread.current[:__web_console_exception]" do
      request = Request.new({})
      request.set_header("action_dispatch.backtrace_cleaner", ActiveSupport::BacktraceCleaner.new)

      Interceptor.call(request, generate_template_error)

      assert_equal 42, Thread.current[:__web_console_exception].bindings.first.eval("@ivar")
    end

    def generate_template_error
      WebConsole::View.new(ActionView::LookupContext.new([])).render(inline: <<~ERB)
        <% @ivar = 42 %>
        <%= nil.raise %>
        </h1
      ERB
    rescue ActionView::Template::Error => err
      err
    end
  end
end
