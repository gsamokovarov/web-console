module WebConsole
  module ExceptionExtension
    prepend_features Exception

    def set_backtrace(*)
      if caller_locations.none? { |loc| loc.path == __FILE__ }
        @__web_console_bindings_stack = binding.callers.drop(1)
      end

      super
    end

    def __web_console_bindings_stack
      @__web_console_bindings_stack || []
    end
  end
end
