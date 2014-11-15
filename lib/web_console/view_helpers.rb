module WebConsole
  module ViewHelpers
    def console(console_binding = nil)
      return unless request.remote_ip.in?(WebConsole.config.whitelisted_ips)

      console_binding ||= binding.of_caller(1)

      unless controller.console_already_rendered
        @console_session = WebConsole::REPLSession.create(binding: console_binding)

        controller.console_already_rendered = true
        render('rescues/web_console')
      end
    end
  end
end
