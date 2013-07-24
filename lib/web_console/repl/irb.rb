require 'irb'
require 'web_console/stream'

module WebConsole
  module REPL
    # == IRB\ Adapter
    #
    # Adapter for the IRB REPL, which is the default Ruby on Rails console.
    class IRB
      class FiberInputMethod < ::IRB::InputMethod
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
        ::IRB.conf[:PROMPT][::IRB.conf[:PROMPT_MODE]][:PROMPT_I]
      end

      def send_input(input)
        Stream.threadsafe_capture! { @fiber.resume("#{input}\n") }
      rescue FiberError
        # Fiber can't be called across threads. So create a new one in the
        # current context.
        @fiber = Fiber.new { @irb.eval_input }.tap(&:resume)
        retry
      end

      private
        def initialize_irb_session!(ap_path = nil)
          ::IRB.init_config(ap_path)
        end

        def finalize_irb_session!
          ::IRB.conf[:MAIN_CONTEXT] = @irb.context
          # Require it after the setting of :MAIN_CONTEXT, as there is code
          # relying on existing :MAIN_CONTEXT that is executed in require time.
        end
    end

    register_adapter IRB do
      require 'rails/console/app'
      require 'rails/console/helpers'

      # Include all of the rails console helpers in the IRB session.
      ::IRB::ExtendCommandBundle.send :include, Rails::ConsoleMethods
    end
  end
end
