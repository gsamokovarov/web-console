require 'test_helper'
require 'web_console/extensions'

module ActionDispatch
  class DebugExceptionsTest < ActionDispatch::IntegrationTest
    class Application
      def call(env)
        ActionView::Base.new.render(inline: '<% @ivar = 42 %> <%= nil.raise %></h1')
      end
    end

    setup do
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('0.0.0.0/0'))

      @app = DebugExceptions.new(Application.new)
    end

    test "follows ActionView::Template::Error original error in env['web_console.exception']" do
      get "/", {}, {
        'action_dispatch.show_detailed_exceptions' => true,
        'action_dispatch.show_exceptions' => true,
        'action_dispatch.logger' => Logger.new(StringIO.new)
      }

      assert_equal 42, request.env['web_console.exception'].bindings.first.eval('@ivar')
    end
  end
end
