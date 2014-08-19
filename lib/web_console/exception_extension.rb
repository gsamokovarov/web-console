class Exception
  attr_accessor :__web_console_bindings_stack

  class << self
    alias :original_new :new

    def new(*args)
      obj = original_new(*args)

      if WebConsole.binding_of_caller_available?
        unless Thread.current[:__web_console_exception_lock]
          Thread.current[:__web_console_exception_lock] = true
          begin
            obj.__web_console_bindings_stack = binding.callers.drop(1)
          ensure
            Thread.current[:__web_console_exception_lock] = false
          end
        end
      end

      obj
    end
  end

  def __web_console_bindings_stack
    @__web_console_bindings_stack || []
  end
end
