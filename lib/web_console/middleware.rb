require 'active_support/core_ext/string/strip'

module WebConsole
  class Middleware
    TEMPLATES_PATH = File.expand_path('../templates', __FILE__)

    DEFAULT_OPTIONS = {
      update_re: %r{/repl_sessions/(?<id>.+?)\z},
      binding_change_re: %r{/repl_sessions/(?<id>.+?)/trace\z}
    }

    UNAVAILABLE_SESSION_MESSAGE = <<-END.strip_heredoc
      Session %{id} is is no longer available in memory.

      If you happen to run on a multi-process server (like Unicorn) the process
      this request hit doesn't store %{id} in memory.
    END

    UNACCEPTABLE_REQUEST_MESSAGE = "A supported version is expected in the Accept header."

    cattr_accessor :whiny_requests
    @@whiny_requests = true

    def initialize(app, options = {})
      @app     = app
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def call(env)
      request = create_regular_or_whiny_request(env)
      return @app.call(env) unless request.from_whitelited_ip?

      if id = id_for_repl_session_update(request)
        return update_repl_session(id, request)
      elsif id = id_for_repl_session_stack_frame_change(request)
        return change_stack_trace(id, request)
      end

      status, headers, body = @app.call(env)

      if exception = env['web_console.exception']
        session = Session.from_exception(exception)
      elsif binding = env['web_console.binding']
        session = Session.from_binding(binding)
      end

      if session && request.acceptable_content_type?
        headers["X-Web-Console-Session-Id"] = session.id
        response = Rack::Response.new(body, status, headers)
        template = Template.new(env, session)

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
        json_response(opts) do
          unless request.acceptable?
            return respond_with_unacceptable_request
          end

          unless session = Session.find(id)
            return respond_with_unavailable_session(id)
          end

          yield session
        end
      end

      def create_regular_or_whiny_request(env)
        request = Request.new(env)
        whiny_requests ? WhinyRequest.new(request) : request
      end

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
