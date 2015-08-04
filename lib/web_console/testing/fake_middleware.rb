require 'action_view'
require 'action_dispatch'
require 'json'
require 'web_console/whitelist'
require 'web_console/request'

module WebConsole
  module Testing
    class FakeMiddleware
      DEFAULT_HEADERS = { "Content-Type" => "application/javascript" }

      def initialize(opts)
        @headers        = opts.fetch(:headers, DEFAULT_HEADERS)
        @req_path_regex = opts[:req_path_regex]
        @view_path      = opts[:view_path]
      end

      def call(env)
        [ 200, @headers, [ render(req_path(env)) ] ]
      end

      def view
        @view ||= create_view
      end

      private

        # extract target path from REQUEST_PATH
        def req_path(env)
          env["REQUEST_PATH"].match(@req_path_regex)[1]
        end

        def render(template)
          view.render(template: template, layout: nil)
        end

        def create_view
          lookup_context = ActionView::LookupContext.new(@view_path)
          lookup_context.cache = false
          FakeView.new(lookup_context)
        end

        class FakeView < ActionView::Base
          def render_inlined_string(template)
            render(template: template, layout: "layouts/inlined_string")
          end
        end
    end
  end
end
