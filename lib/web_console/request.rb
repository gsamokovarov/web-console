# frozen_string_literal: true

module WebConsole
  # Web Console tailored request object.
  class Request < ActionDispatch::Request
    # Configurable set of whitelisted networks.
    cattr_accessor :whitelisted_ips, default: Whitelist.new

    # Returns whether a request came from a whitelisted IP.
    #
    # For a request to hit Web Console features, it needs to come from a white
    # listed IP.
    def from_whitelisted_ip?
      whitelisted_ips.include?(strict_remote_ip)
    end

    # Determines the remote IP using our much stricter whitelist.
    def strict_remote_ip
      GetSecureIp.new(self, whitelisted_ips).to_s
    rescue ActionDispatch::RemoteIp::IpSpoofAttackError
      "[Spoofed]"
    end

    private

      class GetSecureIp < ActionDispatch::RemoteIp::GetIp
        def initialize(req, proxies)
          # After rails/rails@07b2ff0 ActionDispatch::RemoteIp::GetIp initializes
          # with a ActionDispatch::Request object instead of plain Rack
          # environment hash. Keep both @req and @env here, so we don't if/else
          # on Rails versions.
          @req      = req
          @env      = req.env
          @check_ip = true
          @proxies  = proxies
        end

        def filter_proxies(ips)
          ips.reject do |ip|
            @proxies.include?(ip)
          end
        end
      end
  end
end
