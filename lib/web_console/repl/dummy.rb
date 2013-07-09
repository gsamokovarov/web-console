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
        "=> #{@binding.eval(input).inspect}\n"
      rescue Exception => exc
        exc.backtrace.join("\n")
      end
    end

    register_adapter Dummy, standalone: true do
      require 'rails/console/app'
      require 'rails/console/helpers'

      TOPLEVEL_BINDING.eval('self').send(:include, Rails::ConsoleMethods)
    end
  end
end
