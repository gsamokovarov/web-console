require 'active_support/core_ext/string/strip'

module WebConsole
  class Middleware
    TEMPLATES_PATH = File.expand_path('../templates', __FILE__)

    UNAVAILABLE_SESSION_MESSAGE = <<-END.strip_heredoc
      Session %{id} is is no longer available in memory.

      If you happen to run on a multi-process server (like Unicorn or Puma) the process
      this request hit doesn't store %{id} in memory. Consider turning the number of
      processes/workers to one (1) or using a different server in development.
    END

    UNACCEPTABLE_REQUEST_MESSAGE = "A supported version is expected in the Accept header."

    cattr_accessor :mount_point
    @@mount_point = '/__web_console'

    cattr_accessor :whiny_requests
    @@whiny_requests = true

    def initialize(app)
      @app = app
    end

    def call(env)
      logger = if whiny_requests
                 env['action_dispatch.logger'] || WebConsole.logger
               end

      request = Request.new(env, logger)
      return @app.call(env) unless request.from_whitelited_ip?

      if id = id_for_repl_session_update(request)
        return update_repl_session(id, request)
      elsif id = id_for_repl_session_stack_frame_change(request)
        return change_stack_trace(id, request)
      end

      status, headers, body = @app.call(env)
      response = Response.new(body, status, headers, logger)

      if exception = env['web_console.exception']
        session = Session.from_exception(exception)
      elsif binding = env['web_console.binding']
        session = Session.from_binding(binding)
      end

      if session && response.acceptable_content_type?
        template = Template.new(env, session)

        response.headers["X-Web-Console-Session-Id"] = session.id
        response.write(template.render('index'))
        response.finish
      else
        [ status, headers, body ]
      end
    end

    private

      def json_response(opts = {})
        status  = opts.fetch(:status, 200)
        headers = { 'Content-Type' => 'application/json; charset = utf-8' }
        body    = yield.to_json

        Rack::Response.new(body, status, headers).finish
      end

      def json_response_with_session(id, request, opts = {})
        return respond_with_unacceptable_request unless request.acceptable?
        return respond_with_unavailable_session(id) unless session = Session.find(id)

        json_response(opts) { yield session }
      end

      def repl_sessions_re
        @_repl_sessions_re ||= %r{#{mount_point}/repl_sessions/(?<id>[^/]+)}
      end

      def update_re
        @_update_re ||= %r{#{repl_sessions_re}\z}
      end

      def binding_change_re
        @_binding_change_re ||= %r{#{repl_sessions_re}/trace\z}
      end

      def id_for_repl_session_update(request)
        if request.xhr? && request.put?
          update_re.match(request.path) { |m| m[:id] }
        end
      end

      def id_for_repl_session_stack_frame_change(request)
        if request.xhr? && request.post?
          binding_change_re.match(request.path) { |m| m[:id] }
        end
      end

      def update_repl_session(id, request)
        json_response_with_session(id, request) do |session|
          { output: session.eval(request.params[:input]) }
        end
      end

      def change_stack_trace(id, request)
        json_response_with_session(id, request) do |session|
          session.switch_binding_to(request.params[:frame_id])

          { ok: true }
        end
      end

      def respond_with_unavailable_session(id)
        json_response(status: 404) do
          { output: format(UNAVAILABLE_SESSION_MESSAGE, id: id)}
        end
      end

      def respond_with_unacceptable_request
        json_response(status: 406) do
          { error: UNACCEPTABLE_REQUEST_MESSAGE }
        end
      end
  end
end
