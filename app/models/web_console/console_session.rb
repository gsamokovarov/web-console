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
      @repl = WebConsole::REPL.new
    end

    # Decode the input and send it to the underlying process.
    #
    # Decoding algorhithm by Markus Gutschke from http://shellinabox.com.
    def send_input(input)
      @repl.send_input(decode_to_ascii(input))
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

      def decode_to_ascii(input)
        decoded = []
        input.bytes.each_slice(2) do |c0, c1 = 0|
          break if c0 < 48 || (c0 > 57 && c0 < 65) || (c0 > 70 && c0 < 97) || c0 > 102
          break if c1 < 48 || (c1 > 57 && c1 < 65) || (c1 > 70 && c1 < 97) || c1 > 102

          decoded << 16 * ((c0 & 0xF) + 9 * (c0 > 57 ? 1 : 0)) +
                          ((c1 & 0xF) + 9 * (c1 > 57 ? 1 : 0))
        end
        decoded.pack('C*')
      end

      def method_missing(name, *args, &block)
        if @repl.respond_to?(name)
          @repl.send(name, *args, &block)
        else
          super
        end
      end
  end
end
