require 'irb'
require 'stringio'

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

      class StringIOOutputMethod < ::IRB::OutputMethod
        def initialize(io)
          @io = io
        end

        def print(*args)
          args.each { |arg| @io.write(arg) }
        end
      end

      def initialize(binding = TOPLEVEL_BINDING)
        initialize_irb_session!
        @input  = FiberInputMethod.new
        output = StringIOOutputMethod.new(@output = StringIO.new)
        @irb   = ::IRB::Irb.new(::IRB::WorkSpace.new(binding), @input, output)
        @fiber = Fiber.new { @irb.eval_input }.tap(&:resume)
        finalize_irb_session!
      end

      def prompt
        ::IRB.conf[:PROMPT][::IRB.conf[:PROMPT_MODE]][:PROMPT_I]
      end

      def send_input(input)
        @fiber.resume("#{input}\n")
        extract_output!
      end

      private
        def initialize_irb_session!(ap_path = nil)
          ::IRB.init_config(ap_path)
        end

        def finalize_irb_session!
          ::IRB.conf[:MAIN_CONTEXT] = @irb.context
          # Require it after the setting of :MAIN_CONTEXT, as there is code
          # relying on existing :MAIN_CONTEXT that is executed in require time.
          require 'irb/ext/multi-irb'
        end

        def extract_output!
          @output.rewind
          @output.read.lstrip.tap do
            @output.truncate(0)
            @output.rewind
          end
        end
    end

    register_adapter IRB do
      # Freedom patch the reference Irb class so that the unqualified prints go
      # to the context's output method.
      class ::IRB::Irb
        private
          def print(*args)
            @context.instance_variable_get(:@output_method).print(*args)
          end

          def printf(str, *args)
            @context.instance_variable_get(:@output_method).print(str % args)
          end
      end

      require 'rails/console/app'
      require 'rails/console/helpers'

      # Include all of the rails console helpers in the IRB session.
      ::IRB::ExtendCommandBundle.send :include, Rails::ConsoleMethods
    end
  end
end
