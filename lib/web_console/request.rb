module WebConsole
  # Web Console tailored request object.
  class Request < ActionDispatch::Request
    # While most of the servers will return blank content type if none given,
    # Puma will return text/plain.
    cattr_accessor :acceptable_content_types
    @@acceptable_content_types = [Mime::HTML, Mime::TEXT]

    # Configurable set of whitelisted networks.
    cattr_accessor :whitelisted_ips
    @@whitelisted_ips = Whitelist.new

    # Returns whether a request came from a whitelisted IP.
    #
    # For a request to hit Web Console features, it needs to come from a white
    # listed IP.
    def from_whitelited_ip?
      whitelisted_ips.include?(remote_ip)
    end

    # Returns whether the request is from an acceptable content type.
    #
    # We can render a console for HTML and TEXT by default. If a client didn't
    # specified any content type and the server returned it as blank, we'll
    # render it as well.
    def acceptable_content_type?
      content_type.blank? || content_type.in?(acceptable_content_types)
    end
  end
end
