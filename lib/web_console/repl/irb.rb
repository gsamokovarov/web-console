require 'irb'
require 'web_console/fiber'
require 'web_console/stream'

module WebConsole
  module REPL
    # == IRB\ Adapter
    #
    # Adapter for the IRB REPL, which is the default Ruby on Rails console.
    class IRB
      # For some reason™ we have to be ::IRB::StdioInputMethod subclass to get
      # #prompt populated.
      #
      # Not a pretty OOP, but for now, we just have to deal with it.
      class FiberInputMethod < ::IRB::StdioInputMethod
        def initialize; end

        def gets
          @previous = Fiber.yield
        end

        def encoding
          (@previous || '').encoding
        end
      end

      def initialize(binding = TOPLEVEL_BINDING)
        initialize_irb_session!
        @input = FiberInputMethod.new
        @irb   = ::IRB::Irb.new(::IRB::WorkSpace.new(binding), @input)
        @fiber = Fiber.new { @irb.eval_input }.tap(&:resume)
        finalize_irb_session!
      end

      def prompt
        @input.prompt
      end

      def send_input(input)
        Stream.threadsafe_capture! { @fiber.resume("#{input}\n") }
      end

      def send_interrupt
        # Interrupt at :IN_INPUT will cause IRB to print ^C straight to the
        # STDOUT. Avoid that.
        @irb.signal_handle unless @irb.instance_variable_get(:@signal_status) == :IN_INPUT
      end

      private

        def initialize_irb_session!(ap_path = nil)
          ::IRB.init_config(ap_path)
          ::IRB.run_config unless WebConsole.config.prevent_irbrc_execution
        end

        def finalize_irb_session!
          ::IRB.conf[:MAIN_CONTEXT] = @irb.context
        end
    end

    register_adapter IRB do
      require 'rails/console/app'
      require 'rails/console/helpers'

      # Include all of the rails console helpers in the IRB session.
      ::IRB::ExtendCommandBundle.send(:include, Rails::ConsoleMethods)
    end
  end
end
