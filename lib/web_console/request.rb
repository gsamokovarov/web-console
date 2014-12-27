module WebConsole
  # Web Console tailored request object.
  class Request < ActionDispatch::Request
    # Returns whether a request came from a whitelisted IP.
    #
    # For a request to hit Web Console features, it needs to come from a white
    # listed IP.
    def from_whitelited_ip?
      WebConsole.config.whitelisted_ips.include?(remote_ip)
    end

    # Returns whether the request is from an acceptable content type.
    #
    # We can render a console only for HTML. If a client didn't specified any,
    # we'll assume its HTML, because this is common.
    def acceptable_content_type?
      content_type.blank? || Mime::HTML == content_type
    end
  end
end
