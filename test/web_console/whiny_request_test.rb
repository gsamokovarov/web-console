require 'test_helper'

module WebConsole
  class WhinyRequestTest < ActiveSupport::TestCase
    test '#from_whitelited_ip? logs out to stderr' do
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('127.0.0.1'))
      assert_output_to_stderr do
        req = request('http://example.com', 'REMOTE_ADDR' => '0.0.0.0')
        assert_not req.from_whitelited_ip?
      end
    end

    test '#acceptable_content_type? logs out to stderr' do
      Request.stubs(:acceptable_content_types).returns([])
      assert_output_to_stderr do
        req = request('http://example.com', 'CONTENT_TYPE' => 'application/json')
        assert_not req.acceptable_content_type?
      end
    end

    private

      def assert_output_to_stderr
        output = capture(:stderr) { yield }
        assert_not output.blank?
      end

      def request(*args)
        request = Request.new(Rack::MockRequest.env_for(*args))
        WhinyRequest.new(request)
      end
  end
end
