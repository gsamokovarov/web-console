require_dependency "web_console/application_controller"

module WebConsole
  class ConsoleSessionsReplController < ApplicationController
    rescue_from ConsoleSessionREPL::NotFound do |exception|
      render json: exception, status: :gone
    end

    def update
      @console_session = ConsoleSessionREPL.find(params[:id])
      render json: @console_session.save(console_session_params)
    end

    private
      def console_session_params
        params.permit(:input, :id)
      end
  end
end
