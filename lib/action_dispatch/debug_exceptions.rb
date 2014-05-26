module ActionDispatch
  class DebugExceptions
    RESCUES_TEMPLATE_PATH = File.expand_path('../templates', __FILE__)

    private

    def render_exception(env, exception)
      wrapper = ExceptionWrapper.new(env, exception)
      console_session = WebConsole::REPLSession.create binding_from_exception(exception)
      log_error(env, wrapper)

      if env['action_dispatch.show_detailed_exceptions']
        request = Request.new(env)
        template = ActionView::Base.new([RESCUES_TEMPLATE_PATH],
          request: request,
          exception: wrapper.exception,
          application_trace: wrapper.application_trace,
          framework_trace: wrapper.framework_trace,
          full_trace: wrapper.full_trace,
          routes_inspector: routes_inspector(exception),
          source_extract: wrapper.source_extract,
          line_number: wrapper.line_number,
          file: wrapper.file,
          console_session: console_session
        )
        file = "rescues/#{wrapper.rescue_template}"

        if request.xhr?
          body = template.render(template: file, layout: false, formats: [:text])
          format = "text/plain"
        else
          body = template.render(template: file, layout: 'rescues/layout')
          format = "text/html"
        end

        [wrapper.status_code, {'Content-Type' => "#{format}; charset=#{Response.default_charset}", 'Content-Length' => body.bytesize.to_s}, [body]]
      else
        raise exception
      end
    end

    def binding_from_exception(exception)
      exception.__web_console_bindings_stack[0]
    end
  end
end
