require_dependency "web_console/application_controller"

module WebConsole
  class ConsoleSessionsController < ApplicationController
    rescue_from ConsoleSession::NotFound do |exception|
      render json: exception, status: :gone
    end

    def index
      @console_session = ConsoleSession.create
    end

    def input
      @console_session = ConsoleSession.find(params[:id])
      @console_session.send_input(console_session_params[:input])

      render nothing: true
    end

    def pending_output
      @console_session = ConsoleSession.find(params[:id])
      output = @console_session.pending_output

      render json: { output: output }
    end

    private

      def console_session_params
        params.permit(:input)
      end
  end
end
