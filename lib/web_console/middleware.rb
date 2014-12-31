module WebConsole
  class Middleware
    TEMPLATES_PATH = File.expand_path('../templates', __FILE__)

    DEFAULT_OPTIONS = {
      update_re: %r{/repl_sessions/(?<id>.+?)\z},
      binding_change_re: %r{/repl_sessions/(?<id>.+?)/trace\z}
    }

    def initialize(app, options = {})
      @app     = app
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def call(env)
      request = Request.new(env)
      return @app.call(env) unless request.from_whitelited_ip?

      if id = id_for_repl_session_update(request)
        return update_repl_session(id, request.params)
      elsif id = id_for_repl_session_stack_frame_change(request)
        return change_stack_trace(id, request.params)
      end

      status, headers, body = @app.call(env)

      if exception = env['web_console.exception']
        session = Session.from_exception(exception)
      elsif binding = env['web_console.binding']
        session = Session.from_binding(binding)
      end

      if session && request.acceptable_content_type?
        response = Rack::Response.new(body, status, headers)
        template = ActionView::Base.new(TEMPLATES_PATH, session: session)

        response.write(template.render(template: 'session', layout: false))
        response.finish
      else
        [ status, headers, body ]
      end
    end

    private

      def update_re
        @options[:update_re]
      end

      def binding_change_re
        @options[:binding_change_re]
      end

      def id_for_repl_session_update(request)
        if request.xhr? && request.put?
          update_re.match(request.path_info) { |m| m[:id] }
        end
      end

      def id_for_repl_session_stack_frame_change(request)
        if request.xhr? && request.post?
          binding_change_re.match(request.path_info) { |m| m[:id] }
        end
      end

      def update_repl_session(id, params)
        session = Session.find(id)

        status  = 200
        headers = { 'Content-Type' => 'application/json; charset = utf-8' }
        body    = { output: session.eval(params[:input]) }.to_json

        Rack::Response.new(body, status, headers).finish
      end

      def change_stack_trace(id, params)
        session = Session.find(id)
        session.switch_binding_to(params[:frame_id])

        status  = 200
        headers = { 'Content-Type' => 'application/json; charset = utf-8' }
        body    = { ok: true }.to_json

        Rack::Response.new(body, status, headers).finish
      end
  end
end
