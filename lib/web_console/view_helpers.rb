module WebConsole
  module ViewHelpers
    def console(console_binding = nil)
      # This makes sure the console is only rendered once in a template
      @_should_render_console = true if @_should_render_console.nil?

      console_binding ||= binding.of_caller(1)

      if @_should_render_console
        @console_session = WebConsole::REPLSession.create(binding: console_binding)
        @_should_render_console = false

        render('rescues/web_console')
      end
    end
  end
end
