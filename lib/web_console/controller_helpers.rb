module WebConsole
  module ControllerHelpers
    extend ActiveSupport::Concern

    # This makes sure the console is rendered once
    # in a controller session.
    attr_internal_accessor :should_render_console

    included do
      prepend_after_action :render_console
    end

    def initialize
      super
      @_should_render_console = true
    end

    # Helper for capturing a controller binding
    # to prepare for console rendering.
    def console(console_binding = nil)
      if WebConsole.binding_of_caller_available?
        console_binding ||= binding.callers[1]
      end

      @_console_binding = console_binding
    end

    private

    # Attempt to render a web console if a console binding is set.
    # Should only be called as an after_action.
    def render_console
      return unless @_console_binding && @_should_render_console

      console_html = ActionView::Base.new(ActionController::Base.view_paths,
        console_session: REPLSession.create(binding: @_console_binding)
      ).render(partial: 'rescues/web_console')

      response.body = response.body + console_html
    end
  end
end
