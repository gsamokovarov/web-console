module WebConsole
  # Web Console tailored request object.
  class Request < ActionDispatch::Request
    # While most of the servers will return blank content type if none given,
    # Puma will return text/plain.
    cattr_accessor :acceptable_content_types
    @@acceptable_content_types = [Mime::HTML, Mime::TEXT, Mime::URL_ENCODED_FORM]

    # Configurable set of whitelisted networks.
    cattr_accessor :whitelisted_ips
    @@whitelisted_ips = Whitelist.new

    # Define a vendor MIME type. We can call it using Mime::WEB_CONSOLE_V2 constant.
    Mime::Type.register 'application/vnd.web-console.v2', :web_console_v2

    # Returns whether a request came from a whitelisted IP.
    #
    # For a request to hit Web Console features, it needs to come from a white
    # listed IP.
    def from_whitelited_ip?
      whitelisted_ips.include?(strict_remote_ip)
    end

    # Determines the remote IP using our much stricter whitelist.
    def strict_remote_ip
      GetSecureIp.new(env, whitelisted_ips).to_s
    end

    # Returns whether the request is from an acceptable content type.
    #
    # We can render a console for HTML and TEXT by default. If a client didn't
    # specified any content type and the server returned it as blank, we'll
    # render it as well.
    def acceptable_content_type?
      content_type.blank? || content_type.in?(acceptable_content_types)
    end

    # Returns whether the request is acceptable.
    def acceptable?
      xhr? && accepts.any? { |mime| Mime::WEB_CONSOLE_V2 == mime }
    end

    class GetSecureIp < ActionDispatch::RemoteIp::GetIp
      def initialize(env, proxies)
        @env      = env
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
