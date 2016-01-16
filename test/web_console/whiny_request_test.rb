require 'test_helper'

module WebConsole
  class WhinyRequestTest < ActiveSupport::TestCase
    test '#from_whitelisted_ip? logs out to stderr' do
      Request.stubs(:whitelisted_ips).returns(IPAddr.new('127.0.0.1'))
      WebConsole.logger.expects(:info)

      req = request('http://example.com', 'REMOTE_ADDR' => '0.0.0.0')
      assert_not req.from_whitelisted_ip?
    end

    private

      def request(*args)
        request = Request.new(Rack::MockRequest.env_for(*args))
        WhinyRequest.new(request)
      end
  end
end
