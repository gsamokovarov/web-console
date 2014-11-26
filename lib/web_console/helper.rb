module WebConsole
  module Helper
    # Communicates with the middleware to render a console in a +binding+.
    def console(binding = nil)
      request.env['web_console.binding'] ||= (binding || ::Kernel.binding.of_caller(1))

      # Make sure nothing is rendered from the view helper. Otherwise
      # you're gonna see unexpected #<Binding:0x007fee4302b078> in the
      # templates.
      nil
    end
  end
end
