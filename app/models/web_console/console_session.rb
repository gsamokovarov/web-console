module WebConsole
  # Manage and persist (in memory) WebConsole::Slave instances.
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
      def find(pid)
        INMEMORY_STORAGE[pid.to_i] or raise NotFound, 'Session unavailable'
      end

      # Creates an already persisted consolse session.
      #
      # Use this method if you need to persist a session, without providing it
      # any input.
      def create
        new.persist
      end
    end

    def initialize(attributes = {})
      @slave = WebConsole::Slave.new
    end

    # Explicitly persist the model in the in-memory storage.
    def persist
      INMEMORY_STORAGE[pid] = self
    end

    # Returns true if the current session is persisted in the in-memory storage.
    def persisted?
      self == INMEMORY_STORAGE[pid]
    end

    # Returns an Enumerable of all key attributes if any is set, regardless if
    # the object is persisted or not.
    def to_key
      [pid] if persisted?
    end

    private

      def method_missing(name, *args, &block)
        if @slave.respond_to?(name)
          @slave.send(name, *args, &block)
        else
          super
        end
      end
  end
end
