module WebConsole
  # Simple REPL implementation.
  # It uses @binding.eval for code evaluation.
  # No styling or console configurations is supported.
  class REPL
    attr_accessor :binding

    def initialize(binding = TOPLEVEL_BINDING)
      @binding = binding
    end

    def prompt
      '>> '
    end

    def send_input(input)
      eval_result = nil
      eval_result = @binding.eval(input).inspect
      "=> #{eval_result}\n"
    rescue Exception => exc
      "!! #{exc.inspect rescue exc.class.to_s rescue "Exception"}\n"
    end
  end
end
