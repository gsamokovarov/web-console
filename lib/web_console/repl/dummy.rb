require 'web_console/stream'

module WebConsole
  module REPL
    # == Dummy\ Adapter
    #
    # Dummy adapter that is used as a fallback for REPL with no adapters.
    #
    # It provides only the most basic code evaluation with no multiline code
    # support.
    class Dummy
      def initialize(binding = TOPLEVEL_BINDING)
        @binding = binding
      end

      def prompt
        '>> '
      end

      def send_input(input)
        eval_result = nil
        streams_output = Stream.threadsafe_capture! do
          eval_result = @binding.eval(input).inspect
        end
        "#{streams_output}=> #{eval_result}\n"
      rescue Exception => exc
        exc.backtrace.join("\n")
      end
    end

    register_adapter Dummy, standalone: true
  end
end
