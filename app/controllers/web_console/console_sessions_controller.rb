require_dependency "web_console/application_controller"

module WebConsole
  class ConsoleSessionsController < ApplicationController
    rescue_from ConsoleSession::NotFound do |exception|
      render json: exception, status: :gone
    end

    def index
      @console_session = ConsoleSession.create
    end

    def update
      @console_session = ConsoleSession.find(params[:id])
      render json: @console_session.save(console_session_params)
    end

    private

      def console_session_params
        params.permit(:input)
      end
  end
end
