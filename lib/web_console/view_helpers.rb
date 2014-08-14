module WebConsole
  module ViewHelpers
    def console(console_binding = nil)
      # This makes sure the console is only rendered once in a template
      @_should_render_console = true if @_should_render_console.nil?

      if ! console_binding && WebConsole.binding_of_caller_available?
        console_binding = binding.callers[1]
      end

      if @_should_render_console
        @console_session = WebConsole::REPLSession.create(
          binding: console_binding
        )

        @_should_render_console = false
        render('rescues/web_console')
      end
    end
  end
end
