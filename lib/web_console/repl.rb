module WebConsole
  # Simple read–eval–print implementation.
  #
  # Provides only the most basic code evaluation with no multiline code
  # support.
  class REPL
    # Cleanses exceptions raised inside #send_input.
    cattr_reader :cleaner
    @@cleaner = ActiveSupport::BacktraceCleaner.new
    @@cleaner.add_silencer { |line| line.start_with?(File.expand_path('..', __FILE__)) }

    def initialize(binding = TOPLEVEL_BINDING)
      @binding = binding
    end

    def prompt
      '>> '
    end

    def send_input(input)
      "=> #{@binding.eval(input).inspect}\n"
    rescue Exception => exc
      format_exception(exc)
    end

    private

      def format_exception(exc)
        backtrace = cleaner.clean(Array(exc.backtrace) - caller)

        format = "#{exc.class.name}: #{exc}\n"
        format << backtrace.map { |trace| "\tfrom #{trace}\n" }.join
        format
      end
  end
end
