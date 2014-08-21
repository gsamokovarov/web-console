module ActionDispatch
  class DebugExceptions
    RESCUES_TEMPLATE_PATH.replace(File.expand_path('../templates', __FILE__))

    def call(env)
      request = Request.new(env)

      if request.put? && m = env["PATH_INFO"].match(%r{/repl_sessions/(?<id>.+?)\z})
        update_repl_session(m[:id], request.params[:input])
      elsif request.post? && m = env["PATH_INFO"].match(%r{/repl_sessions/(?<id>.+?)/trace\z})
        change_stack_trace(m[:id], request.params[:frame_id])
      else
        middleware_call(env)
      end
    end

    def middleware_call(env)
      _, headers, body = response = @app.call(env)

      if headers['X-Cascade'] == 'pass'
        body.close if body.respond_to?(:close)
        raise ActionController::RoutingError, "No route matches [#{env['REQUEST_METHOD']}] #{env['PATH_INFO'].inspect}"
      end

      response
    rescue Exception => exception
      raise exception if env['action_dispatch.show_exceptions'] == false
      render_exception(env, exception)
    end

    private

      def update_repl_session(id, input)
        console_session = WebConsole::REPLSession.find(id)
        response = console_session.save(input: input)
        [ 200, { "Content-Type" => "text/plain; charset=utf-8" }, [ response.to_json ] ]
      end

      def change_stack_trace(id, frame_id)
        console_session = WebConsole::REPLSession.find(id)
        binding = console_session.binding_stack[frame_id.to_i]
        console_session.binding = binding
        [ 200, { "Content-Type" => "text/plain; charset=utf-8" }, [ JSON.dump("success") ] ]
      end

      def render_exception(env, exception)
        if exception.respond_to?(:original_exception) && exception.original_exception
          exception = exception.original_exception
        end

        wrapper = ExceptionWrapper.new(env, exception)
        traces = traces_from_wrapper(wrapper)
        extract_sources = wrapper.extract_sources
        console_session = WebConsole::REPLSession.create(
          binding: binding_from_exception(exception),
          binding_stack: exception.__web_console_bindings_stack
        )
        log_error(env, wrapper)

        if env['action_dispatch.show_detailed_exceptions']
          request = Request.new(env)
          template = ActionView::Base.new([ RESCUES_TEMPLATE_PATH ],
            request: request,
            exception: wrapper.exception,
            application_trace: traces[:application_trace],
            framework_trace: traces[:framework_trace],
            full_trace: traces[:full_trace],
            routes_inspector: routes_inspector(exception),
            extract_sources: extract_sources,
            console_session: console_session
          )
          file = "rescues/#{wrapper.rescue_template}"

          if request.xhr?
            body = template.render(template: file, layout: false, formats: [ :text ])
            format = "text/plain"
          else
            body = template.render(template: file, layout: 'rescues/layout')
            format = "text/html"
          end

          [ wrapper.status_code, { 'Content-Type' => "#{format}; charset=#{Response.default_charset}", 'Content-Length' => body.bytesize.to_s }, [ body ] ]
        else
          raise exception
        end
      end

      # Augment the exception traces by providing ids for all unique stack frames.
      def traces_from_wrapper(wrapper)
        id_counter = 0

        application_trace = wrapper.application_trace.map do |trace|
          prev = id_counter
          id_counter += 1
          { id: prev, trace: trace }
        end

        framework_trace = wrapper.framework_trace.map do |trace|
          prev = id_counter
          id_counter += 1
          { id: prev, trace: trace }
        end

        {
          application_trace: application_trace,
          framework_trace: framework_trace,
          full_trace: application_trace + framework_trace
        }
      end

      def binding_from_exception(exception)
        exception.__web_console_bindings_stack[0]
      end
  end
end
