require_dependency "web_console/application_controller"

module WebConsole
  class ReplSessionsController < ApplicationController
    rescue_from REPLSession::NotFound do |exception|
      render json: exception, status: :gone
    end

    def update
      @console_session = REPLSession.find(params[:id])
      render json: @console_session.save(console_session_params)
    end

    def trace
      @console_session = REPLSession.find(params[:id])
      binding = @console_session.binding_stack[Integer(params[:frame_id])]
      @console_session.binding = binding
      render json: "success"
    end

    private
      def console_session_params
        params.permit(:input, :id)
      end
  end
end
