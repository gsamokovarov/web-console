module WebConsole
  class FlatScenario
    def call
      raise
    rescue => exc
      exc
    end
  end
end
