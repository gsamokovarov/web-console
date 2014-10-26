class Exception
  # The bindings in which the exception originated in.
  def bindings
    @bindings || []
  end

  # JRuby won't call Exception#set_backtrace when raising, so we can't hook in
  # there. Our best bet is to hook into Exception#initialize, however we have
  # the problem that a subclass may forget to call super in its override.
  def initialize_with_binding_of_caller(*args)
    unless Thread.current[:__web_console_exception_lock]
      Thread.current[:__web_console_exception_lock] = true
      begin
        @bindings = binding.callers.drop(1)
      ensure
        Thread.current[:__web_console_exception_lock] = false
      end
    end

    initialize_without_binding_of_caller(*args)
  end

  alias_method_chain :initialize, :binding_of_caller
end

