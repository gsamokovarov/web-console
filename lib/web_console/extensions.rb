module Kernel
  module_function

  # Instructs Web Console to render a console in the specified binding.
  #
  # If +bidning+ isn't explicitly given it will default to the binding of the
  # previous frame. E.g. the one that invoked +console+.
  #
  # Raises DoubleRenderError if a double +console+ invocation per request is
  # detected.
  def console(binding = WebConsole.caller_bindings.first)
    raise WebConsole::DoubleRenderError if Thread.current[:__web_console_binding]

    Thread.current[:__web_console_binding] = binding

    # Make sure nothing is rendered from the view helper. Otherwise
    # you're gonna see unexpected #<Binding:0x007fee4302b078> in the
    # templates.
    nil
  end
end
