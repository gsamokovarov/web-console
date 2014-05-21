require "cgi"
require "json"

module WebConsole
  class ErrorPage
    TEMPLATE_PATH = File.expand_path("../templates", __FILE__)

    attr_reader :exception, :env

    def initialize(exception, env)
      @exception = real_exception(exception)
      @console_session = REPLSession.create binding_from_exception
      @env = env
    end

    def template
      @template ||= ActionView::Base.new([TEMPLATE_PATH],
        exception: @exception,
        console_session: @console_session
      )
    end

    def render(template_name = "main")
      template.render(template: "#{template_name}.erb")
    end

  private
    def binding_from_exception
      @exception.__web_console_bindings_stack[0]
    end

    def real_exception(exception)
      if exception.respond_to?(:original_exception) && exception.original_exception.is_a?(Exception)
        exception.original_exception
      else
        exception
      end
    end
  end
end
