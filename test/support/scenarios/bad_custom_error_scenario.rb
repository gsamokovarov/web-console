module WebConsole
  class BadCustomErrorScenario
    class Error < StandardError
      def initialize(*)
        # Bad exceptions are exceptions that don't call super in there
        # #initialize method.
      end
    end

    def call
      raise Error
    rescue => exc
      exc
    end
  end
end

