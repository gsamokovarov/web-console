module WebConsole
  class ConsoleSession
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    LOCK = Mutex.new # :nodoc:

    # In-memory storage for the console sessions. Session preservation is
    # troubled on servers with multiple workers and threads.
    INMEMORY_STORAGE = {}

    # Store and define the available attributes.
    ATTRIBUTES = [ :id, :input, :output, :prompt ].each do |attr|
      attr_accessor attr
    end

    # Raised when trying to find a session that is no longer in the in-memory
    # session storage.
    Expired = Class.new(Exception)

    class << self
      # Finds a session by its id.
      #
      # Raises WebConsole::ConsoleSession::Expired if there is no such session.
      def find(id)
        INMEMORY_STORAGE[id] or raise Expired
      end

      protected
        # Generates a consequential id number in a thread-safe manner.
        def next_id!
          LOCK.synchronize do
            @counter ||= 0
            @counter += 1
          end
        end
    end

    def inititalize(attributes = {})
      ensure_consequential_id!(attributes)
      super
      @repl = WebConsole::REPL.default.new
    end

    # Returns true if the current session is persisted in the in-memory storage.
    def persisted?
      self == INMEMORY_STORAGE[id]
    end

    # Returns true if the console session has expired or hasn't been persisted.
    def expired?
      ! persisted?
    end

    protected
      # Returns a hash of the attributes and their values.
      #
      # Used by the JSON serializer.
      def attributes
        ATTRIBUTES.each_with_object({}) do |attr, memo|
          memo[attr] = public_send(attr)
        end
      end

      # Sets model attributes from a hash.
      #
      # Used by the JSON serializer.
      def attributes=(attributes)
        attributes.each do |attr, value|
          next unless ATTRIBUTES.include?(attr.to_sym)
          public_send(:"#{attr}=", value)
        end
      end

    private
      def ensure_consequential_id!(attributes)
        attributes[:id] ||= self.class.next_id!
        attributes
      end
  end
end
