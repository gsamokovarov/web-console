module WebConsole
  module ViewHelpers
    def console(console_binding = nil)
      console_binding ||= binding.of_caller(1)

      if controller.should_render_console
        @console_session = WebConsole::REPLSession.create(binding: console_binding)

        controller.should_render_console = false
        render('rescues/web_console')
      end
    end
  end
end
