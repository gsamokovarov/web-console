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
        @io    = StringIO.new
        input  = StringIOInputMethod.new(@io)
        output = StringIOOutputMethod.new(@io)
        @irb   = ::IRB::Irb.new(::IRB::WorkSpace.new(binding), input, output)
        finalize_irb_session!
      end

      delegate :prompt, to: :@io, allow_nil: true

      def send_input(input)
        replace_input!(input)
        @irb.eval_input
        @io.rewind
        @io.read
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
          @io.truncate(0)
          @io.rewind
          @io.write(input)
          @io.rewind
        end
    end

    register_adapter IRB
  end
end
