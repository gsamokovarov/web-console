require 'test_helper'

module WebConsole
  class RequestTest < ActiveSupport::TestCase
    setup do
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('127.0.0.1'))
    end

    test '#from_whitelited_ip? is falsy for blacklisted IPs' do
      req = request('http://example.com', 'REMOTE_ADDR' => '0.0.0.0')

      assert_not req.from_whitelited_ip?
    end

    test '#from_whitelited_ip? is truthy for whitelisted IPs' do
      req = request('http://example.com', 'REMOTE_ADDR' => '127.0.0.1')

      assert req.from_whitelited_ip?
    end

    test '#from_whitelisted_ip? is truthy for whitelisted IPs via whitelisted proxies' do
      req = request('http://example.com', 'REMOTE_ADDR' => '127.0.0.1', 'HTTP_X_FORWARDED_FOR' => '127.0.0.0')

      assert req.from_whitelited_ip?
    end

    test '#from_whitelisted_ip? is falsy for blacklisted IPs via whitelisted proxies' do
      req = request('http://example.com', 'REMOTE_ADDR' => '127.0.0.1', 'HTTP_X_FORWARDED_FOR' => '0.0.0.0')

      assert_not req.from_whitelited_ip?
    end

    test '#from_whitelisted_ip? is falsy for lying blacklisted IPs via whitelisted proxies' do
      req = request('http://example.com', 'REMOTE_ADDR' => '127.0.0.1', 'HTTP_X_FORWARDED_FOR' => '10.0.0.0, 127.0.0.0')

      assert_not req.from_whitelited_ip?
    end

    test '#from_whitelisted_ip? is falsy for whitelisted IPs via blacklisted proxies' do
      req = request('http://example.com', 'REMOTE_ADDR' => '10.0.0.0', 'HTTP_X_FORWARDED_FOR' => '127.0.0.0')

      assert_not req.from_whitelited_ip?
    end

    test '#acceptable_content_type? is truthy for explicit HTML content type' do
      html = request('http://example.com', 'CONTENT_TYPE' => 'text/html')
      xhtml = request('http://example.com', 'CONTENT_TYPE' => 'application/xhtml+xml')

      [ html, xhtml ].each { |req| assert req.acceptable_content_type? }
    end

    test '#acceptable_content_type? is truthy for plain text content type' do
      req = request('http://example.com', 'CONTENT_TYPE' => 'text/plain')

      assert req.acceptable_content_type?
    end

    test '#acceptable_content_type? is truthy during form submission' do
      req = request('http://example.com', 'CONTENT_TYPE' => 'application/x-www-form-urlencoded')

      assert req.acceptable_content_type?
    end

    test '#acceptable_content_type? is truthy for blank content type' do
      req = request('http://example.com', 'CONTENT_TYPE' => '')

      assert req.acceptable_content_type?
    end

    test '#acceptable_content_type? is falsy for non blank and non HTML content type' do
      req = request('http://example.com', 'CONTENT_TYPE' => 'application/json')

      assert_not req.acceptable_content_type?
    end

    test '#acceptable? is truthy for current version' do
      req = xhr('http://example.com', 'HTTP_ACCEPT' => "#{Mime::WEB_CONSOLE_V2}")

      assert req.acceptable?
    end

    test '#acceptable? is falsy for request without vendor mime type' do
      req = xhr('http://example.com', 'HTTP_ACCEPT' => 'text/plain; charset=utf-8')

      assert_not req.acceptable?
    end

    private

      def request(*args)
        Request.new(Rack::MockRequest.env_for(*args))
      end

      def xhr(*args)
        args[1]['HTTP_X_REQUESTED_WITH'] ||= 'XMLHttpRequest'
        request(*args)
      end
  end
end
