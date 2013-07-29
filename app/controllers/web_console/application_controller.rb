module WebConsole
  class ApplicationController < ActionController::Base
    before_action :prevent_unauthorized_requests!

    private
      def prevent_unauthorized_requests!
        unless request.remote_ip.in?(WebConsole::Engine.config.web_console.whitelisted_ips)
          render nothing: true, status: :unauthorized
        end
      end
  end
end
