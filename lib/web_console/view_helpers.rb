module WebConsole
  module ViewHelpers
    def console
      p binding.callers
      @should_render = true if @should_render.nil?

      if @should_render
        @console_session = WebConsole::REPLSession.create(
          binding: binding.callers[1]
        )

        @should_render = false
        render('rescues/repl_console_js') + render('rescues/web_console')
      end
    end
  end
end
