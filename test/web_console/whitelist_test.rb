module WebConsole
  class WhitelistTest < ActiveSupport::TestCase
    test 'localhost is always whitelisted' do
      whitelisted_ips = whitelist('8.8.8.8')

      assert_includes whitelisted_ips, '127.0.0.1'
      assert_includes whitelisted_ips, '::1'
    end

    test 'can whitelist single IPs' do
      whitelisted_ips = whitelist('8.8.8.8')

      assert_includes whitelisted_ips, '8.8.8.8'
    end

    test 'can whitelist whole networks' do
      whitelisted_ips = whitelist('172.16.0.0/12')

      1.upto(255).each do |n|
        assert_includes whitelisted_ips, "172.16.0.#{n}"
      end
    end

    test 'can whitelist multiple networks' do
      whitelisted_ips = whitelist %w(172.16.0.0/12 192.168.0.0/16)

      1.upto(255).each do |n|
        assert_includes whitelisted_ips, "172.16.0.#{n}"
        assert_includes whitelisted_ips, "192.168.0.#{n}"
      end
    end

    test 'can be represented in a human readable form' do
      assert_includes whitelist.to_s, '127.0.0.0/127.255.255.255, ::1'
    end

    private

      def whitelist(*args)
        Whitelist.new(*args)
      end
  end
end
