module WebConsole
  # A session lets you persist wrap an +Evaluator+ instance in memory
  # associated with multiple bindings.
  #
  # Each newly created session is persisted into memory and you can find it
  # later its +id+.
  #
  # A session may be associated with multiple bindings. This is used by the
  # error pages only, as currently, this is the only client that needs to do
  # that.
  class Session
    INMEMORY_STORAGE = {}

    class NotFound < Error
      def as_json(*)
        { error: message }
      end
    end

    class << self
      # Finds a persisted session in memory by its id.
      #
      # Returns a persisted session if found in memory.
      # Raises NotFound error unless found in memory.
      def find(id)
        INMEMORY_STORAGE[id] or raise NotFound, 'Session unavailable'
      end

      # Create a Session from an exception.
      def from_exception(exc)
        new(exc.bindings)
      end

      alias from_binding new
      alias from_bindings new
    end

    # An unique identifier for every REPL.
    attr_reader :id

    def initialize(*bindings)
      @id = SecureRandom.hex(16)
      @bindings = bindings.flatten
      @evaluator = Evaluator.new(@bindings.first)

      store_into_memory
    end

    # Evaluate +input+ on the current Evaluator associated binding.
    #
    # Returns a string of the Evaluator output.
    def eval(input)
      @evaluator.eval(input)
    end

    # Switches the current binding to the one at specified +index+.
    #
    # Returns nothing.
    def switch_binding_to(index)
      @evaluator = Evaluator.new(@bindings[index.to_i])
    end

    # Whether this session is special cased for the error page.
    #
    # The error page is special, because its the only page that requires
    # multiple bindings.
    #
    # Returns true when there are multiple binding or false otherwise.
    def for_error_page?
      @bindings.count > 1
    end

    private

      def store_into_memory
        INMEMORY_STORAGE[id] = self
      end
  end
end
