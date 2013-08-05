module WebConsole
  class ApplicationController < ActionController::Base
    class << self
      # Alias before_filter to before_action for Rails 3 compatibility.
      alias :before_action :before_filter unless defined?(before_filter)
    end

    before_action :prevent_unauthorized_requests!

    private
      def prevent_unauthorized_requests!
        unless request.remote_ip.in?(WebConsole.config.whitelisted_ips)
          render nothing: true, status: :unauthorized
        end
      end
  end
end
