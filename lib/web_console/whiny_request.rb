module WebConsole
  # Noisy wrapper around +Request+.
  #
  # If any calls to +from_whitelisted_ip?+ and +acceptable_content_type?+
  # return false, an info log message will be displayed in users' logs.
  class WhinyRequest < SimpleDelegator
    def from_whitelited_ip?
      whine_unless request.from_whitelited_ip? do
        "Cannot render console from #{request.remote_ip}! " \
          "Allowed networks: #{request.whitelisted_ips}"
      end
    end

    def acceptable_content_type?
      whine_unless request.acceptable_content_type? do
        "Cannot render console with content type #{request.content_type}" \
          "Allowed content types: #{request.acceptable_content_types}"
      end
    end

    private

      def whine_unless(condition)
        unless condition
          logger.info { yield }
        end
        condition
      end

      def logger
        env['action_dispatch.logger'] || WebConsole.logger
      end

      def request
        __getobj__
      end
  end
end
