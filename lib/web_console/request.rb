module WebConsole
  # Web Console tailored request object.
  class Request < ActionDispatch::Request
    # For a request to hit Web Console features, it needs to come from a
    # white listed IP and to be XMLHttpRequest.
    def from_whitelited_ip?
      WebConsole.config.whitelisted_ips.include?(remote_ip)
    end

    # An acceptable content type for Web Console is HTML only.
    # If a client didn't specified it, we'll assume its HTML.
    def acceptable_content_type?
      content_type.blank? || Mime::HTML == content_type
    end
  end
end
