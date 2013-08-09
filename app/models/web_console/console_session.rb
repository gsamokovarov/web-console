module WebConsole
  # Manage and persist (in memory) WebConsole::REPL instances.
  class ConsoleSession
    include ActiveModel::Model

    # In-memory storage for the console sessions. Session preservation is
    # troubled on servers with multiple workers and threads.
    INMEMORY_STORAGE = {}

    # Raised when trying to find a session that is no longer in the in-memory
    # session storage.
    class NotFound < Exception
      def to_json(*)
        { error: message }.to_json
      end
    end

    class << self
      # Finds a session by its pid.
      #
      # Raises WebConsole::ConsoleSession::Expired if there is no such session.
      def find(id)
        INMEMORY_STORAGE[id.to_i] or raise NotFound, 'Session unavailable'
      end

      # Creates an already persisted consolse session.
      #
      # Use this method if you need to persist a session, without providing it
      # any input.
      def create
        INMEMORY_STORAGE[(model = new).pid] = model
      end
    end

    delegate :pid, :send_input, :send_interrupt, :pending_output,
             to: '@repl', allow_nil: true

    alias :id :pid

    def initialize(attributes = {})
      @repl = WebConsole::REPL.new
    end

    # Returns true if the current session is persisted in the in-memory storage.
    def persisted?
      self == INMEMORY_STORAGE[pid]
    end

    # Returns an Enumerable of all key attributes if any is set, regardless if
    # the object is persisted or not.
    def to_key
      super if persisted?
    end
  end
end
