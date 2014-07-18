class Exception
  original_set_backtrace = instance_method(:set_backtrace)

  if WebConsole.binding_of_caller_available
    define_method :set_backtrace do |*args|
      unless Thread.current[:__web_console_exception_lock]
        Thread.current[:__web_console_exception_lock] = true
        begin
          @__web_console_bindings_stack = binding.callers.drop(1)
        ensure
          Thread.current[:__web_console_exception_lock] = false
        end
      end

      original_set_backtrace.bind(self).call(*args)
    end
  end

  def __web_console_bindings_stack
    @__web_console_bindings_stack || []
  end
end
