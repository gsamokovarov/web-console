module WebConsole
  # Web Console tailored request object.
  class Request < ActionDispatch::Request
    # While most of the servers will return blank content type if none given,
    # Puma will return text/plain.
    ACCEPTABLE_CONTENT_TYPE = [Mime::HTML, Mime::TEXT]

    # Returns whether a request came from a whitelisted IP.
    #
    # For a request to hit Web Console features, it needs to come from a white
    # listed IP.
    def from_whitelited_ip?
      WebConsole.config.whitelisted_ips.include?(remote_ip)
    end

    # Returns whether the request is from an acceptable content type.
    #
    # We can render a console for HTML and TEXT. If a client didn't
    # specified any content type, we'll render it as well.
    def acceptable_content_type?
      content_type.blank? || content_type.in?(ACCEPTABLE_CONTENT_TYPE)
    end
  end
end
