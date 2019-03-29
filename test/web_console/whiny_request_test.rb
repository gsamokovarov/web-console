# frozen_string_literal: true

require "test_helper"

module WebConsole
  class WhinyRequestTest < ActiveSupport::TestCase
    test "#permitted? logs out to stderr" do
      Request.stubs(:permissions).returns(IPAddr.new("127.0.0.1"))
      WebConsole.logger.expects(:info)

      req = request("http://example.com", "REMOTE_ADDR" => "0.0.0.0")
      assert_not req.permitted?
    end

    test "#permitted? is falsy for spoofed IPs" do
      WebConsole.logger.expects(:info)
      req = request("http://example.com", "HTTP_CLIENT_IP" => "127.0.0.1", "HTTP_X_FORWARDED_FOR" => "127.0.0.0")

      assert_not req.permitted?
    end

    private

      def request(*args)
        request = Request.new(Rack::MockRequest.env_for(*args))
        WhinyRequest.new(request)
      end
  end
end
