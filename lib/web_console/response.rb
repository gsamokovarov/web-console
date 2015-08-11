module WebConsole
  # Web Console tailored response object.
  class Response < Rack::Response
    def initialize(body, status, headers, logger = nil)
      @logger = logger
      super(body, status, headers)
    end

    # Returns whether the response is from an acceptable content type.
    #
    # We can render a console only for HTML responses.
    def acceptable_content_type?
      if content_type == Mime::HTML
        true
      else
        log_not_acceptable_content_type
        false
      end
    end

    def content_type
      formats = Mime::Type.parse(headers['Content-Type'])
      formats.first
    end

    private

      attr_reader :logger

      def log_not_acceptable_content_type
        if logger
          logger.info "Cannot render console with content type " \
            "#{content_type}. Console can be rendered only in HTML responses"
        end
      end
  end
end
