require 'irb'
require 'irb/frame'
require 'stringio'
require 'active_support/core_ext/module/delegation'


module WebConsole
  module REPL
    # == IRB\ Adapter
    #
    # Adapter for the IRB REPL, which is the default Ruby on Rails console.
    class IRB
      # Monkey patch the reference Irb class to use it's specified output
      # method during printing.
      class ::IRB::Irb
        def print(*args)
          @context.instance_variable_get(:@output_method).print(*args)
        end

        def printf(str, *args)
          @context.instance_variable_get(:@output_method).print(str % args)
        end
      end

      class StringIOInputMethod < ::IRB::InputMethod
        def initialize(io)
          @io = io
        end

        delegate :eof?, :gets, to: :@io, allow_nil: true

        def encoding
          @io.external_encoding
        end
      end

      class StringIOOutputMethod < ::IRB::OutputMethod
        def initialize(io)
          @io = io
        end

        def print(*args)
          @io.write(*args)
        end
      end

      def initialize(binding = ::IRB::Frame.top(1))
        initialize_irb_session!
        input  = StringIOInputMethod.new(@input = StringIO.new)
        output = StringIOOutputMethod.new(@output = StringIO.new)
        @irb   = ::IRB::Irb.new(::IRB::WorkSpace.new(binding), input, output)
        finalize_irb_session!
      end

      def prompt
        ::IRB.conf[:PROMPT][::IRB.conf[:PROMPT_MODE]][:RETURN]
      end

      def send_input(input)
        replace_input!(input)
        @irb.eval_input
        extract_output!
      end

      private
        def initialize_irb_session!(ap_path = nil)
          ::IRB.init_config(ap_path)
        end

        def finalize_irb_session!
          ::IRB.conf[:MAIN_CONTEXT] = @irb.context
          # Require it after the setting of :MAIN_CONTEXT, as there is code
          # relying on it that is executed during require time.
          require 'irb/ext/multi-irb'
        end

        def replace_input!(input)
          # The rewinds are important here. StringIO#truncate will nullify the
          # underlying string, but won't change the current position. Therefore,
          # the next write may be preceeded by leading +\u0000+ characters.
          @input.truncate(0)
          @input.rewind
          @input.write(input)
          @input.rewind
        end

        def extract_output!
          @output.rewind
          @output.read.lstrip.tap do
            @output.truncate(0)
            @output.rewind
          end
        end
    end

    register_adapter IRB
  end
end
