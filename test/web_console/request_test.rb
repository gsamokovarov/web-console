# frozen_string_literal: true

require "test_helper"

module WebConsole
  class RequestTest < ActiveSupport::TestCase
    setup do
      Request.stubs(:whitelisted_ips).returns(IPAddr.new("127.0.0.1"))
    end

    test "#from_whitelisted_ip? is falsy for blacklisted IPs" do
      req = request("http://example.com", "REMOTE_ADDR" => "0.0.0.0")

      assert_not req.from_whitelisted_ip?
    end

    test "#from_whitelisted_ip? is truthy for whitelisted IPs" do
      req = request("http://example.com", "REMOTE_ADDR" => "127.0.0.1")

      assert req.from_whitelisted_ip?
    end

    test "#from_whitelisted_ip? is truthy for whitelisted IPs via whitelisted proxies" do
      req = request("http://example.com", "REMOTE_ADDR" => "127.0.0.1", "HTTP_X_FORWARDED_FOR" => "127.0.0.0")

      assert req.from_whitelisted_ip?
    end

    test "#from_whitelisted_ip? is falsy for blacklisted IPs via whitelisted proxies" do
      req = request("http://example.com", "REMOTE_ADDR" => "127.0.0.1", "HTTP_X_FORWARDED_FOR" => "0.0.0.0")

      assert_not req.from_whitelisted_ip?
    end

    test "#from_whitelisted_ip? is falsy for lying blacklisted IPs via whitelisted proxies" do
      req = request("http://example.com", "REMOTE_ADDR" => "127.0.0.1", "HTTP_X_FORWARDED_FOR" => "10.0.0.0, 127.0.0.0")

      assert_not req.from_whitelisted_ip?
    end

    test "#from_whitelisted_ip? is falsy for whitelisted IPs via blacklisted proxies" do
      req = request("http://example.com", "REMOTE_ADDR" => "10.0.0.0", "HTTP_X_FORWARDED_FOR" => "127.0.0.0")

      assert_not req.from_whitelisted_ip?
    end

    test "#from_whitelisted_ip? is falsy for spoofed IPs" do
      req = request("http://example.com", "HTTP_CLIENT_IP" => "127.0.0.1", "HTTP_X_FORWARDED_FOR" => "127.0.0.0")

      assert_not req.from_whitelisted_ip?
    end

    private

      def request(*args)
        Request.new(mock_env(*args))
      end

      def mock_env(*args)
        Rack::MockRequest.env_for(*args)
      end

      def xhr(*args)
        args[1]["HTTP_X_REQUESTED_WITH"] ||= "XMLHttpRequest"
        request(*args)
      end
  end
end
