require_dependency "web_console/application_controller"

module WebConsole
  class ConsoleSessionsController < ApplicationController
    def index
      @console_session = ConsoleSession.create
    end

    def update
      @console_session = ConsoleSession.find(params[:id])

      if @console_session.save(console_session_params)
        render json: @console_session
      else
        render json: @console_session.errors, status: :unprocessable_entry
      end
    end

    private
      def console_session_params
        params.permit(:input)
      end
  end
end
