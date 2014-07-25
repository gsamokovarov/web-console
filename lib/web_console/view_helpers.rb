module WebConsole
  module ViewHelpers
    def console
      @_should_render_console = true if @_should_render_console.nil?

      if @_should_render_console
        @console_session = WebConsole::REPLSession.create(
          binding: binding.callers[1]
        )

        @_should_render_console = false
        render('rescues/web_console')
      end
    end
  end
end
