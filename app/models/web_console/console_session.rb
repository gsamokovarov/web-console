module WebConsole
  class ConsoleSession
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    # In-memory storage for the console sessions. Session preservation is
    # troubled on servers with multiple workers and threads.
    INMEMORY_STORAGE = {}

    # Store and define the available attributes.
    ATTRIBUTES = [ :id, :input, :output, :prompt ].each do |attr|
      attr_accessor attr
    end

    # Raised when trying to find a session that is no longer in the in-memory
    # session storage.
    NotFound = Class.new(Exception)

    class << self
      # Finds a session by its id.
      #
      # Raises WebConsole::ConsoleSession::Expired if there is no such session.
      def find(id)
        INMEMORY_STORAGE[id.to_i] or raise NotFound
      end

      # Creates an already persisted consolse session.
      #
      # Use this method if you need to persist a session, without providing it
      # any input.
      def create
        INMEMORY_STORAGE[(model = new).id] = model
      end
    end

    validates :input, presence: true

    def initialize(attributes = {})
      @repl = WebConsole::REPL.default.new

      super
      ensure_consequential_id!
      populate_repl_attributes!
    end

    # Saves the model into the in-memory storage.
    #
    # Returns false if the model is not valid (e.g. its missing input).
    def save(attributes = {})
      self.attributes = attributes if attributes.present?
      if valid?
        populate_repl_attributes!
        store!
      else
        false
      end
    end

    # Returns true if the current session is persisted in the in-memory storage.
    def persisted?
      self == INMEMORY_STORAGE[id]
    end

    # Returns an Enumerable of all key attributes if any is set, regardless if
    # the object is persisted or not.
    def to_key
      super if persisted?
    end

    protected
      # Returns a hash of the attributes and their values.
      def attributes
        return Hash[ATTRIBUTES.zip([nil])]
      end

      # Sets model attributes from a hash.
      def attributes=(attributes)
        attributes.each do |attr, value|
          next unless ATTRIBUTES.include?(attr.to_sym)
          public_send(:"#{attr}=", value)
        end
      end

    private
      LOCK = Mutex.new # :nodoc:

      def ensure_consequential_id!
        self.id ||= LOCK.synchronize do
          @@counter ||= 0
          @@counter += 1
        end
      end

      def populate_repl_attributes!
        LOCK.synchronize do
          self.output = @repl.send_input(input) if input.present?
          self.prompt = @repl.prompt
        end
      end

      def store!
        LOCK.synchronize { INMEMORY_STORAGE[id] = self }
      end
  end
end
