module WebConsole
  module ViewHelpers
    def console
      @console_session = WebConsole::REPLSession.create(
        binding: binding.callers[0]
      )

      render('rescues/repl_console_js') + render('rescues/web_console')
    end
  end
end
