class Exception
  # The bindings in which the exception originated in.
  def bindings
    @bindings || []
  end

  # Rubinius, as JRuby, won't call Exception#set_backtrace. This means we'll
  # miss custom exceptions overriding #initialize, but forgetting to call
  # super.
  def initialize_with_binding_of_caller(*args)
    unless Thread.current[:__web_console_exception_lock]
      Thread.current[:__web_console_exception_lock] = true
      begin
        @bindings = binding.callers.drop(2)

        # When explicitly raising an exception, we have to drop one more frame
        # on Rubinius. The way we do it is pretty bad as it strongly depends on
        # the Kerner#raise implementation details. We need to do better in the
        # future.
        if _ = @bindings.first and _.eval('local_variables') == [:exc, :msg, :ctx, :skip, :loc, :pos]
          @bindings.shift
        end
      ensure
        Thread.current[:__web_console_exception_lock] = false
      end
    end

    initialize_without_binding_of_caller(*args)
  end

  alias_method_chain :initialize, :binding_of_caller
end
