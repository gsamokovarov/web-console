module WebConsole
  class REPLSession
    include Mutex_m

    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    INMEMORY_STORAGE = {}

    ATTRIBUTES = [ :id, :input, :output, :prompt, :binding, :binding_stack ].each do |attr|
      attr_accessor attr
    end

    class NotFound < StandardError
      def to_json(*)
        { error: message }.to_json
      end
    end

    class << self
      # Finds a session by its id.
      def find(id)
        INMEMORY_STORAGE[id.to_i] or raise NotFound.new('Session unavailable')
      end

      # Creates an already persisted consolse session.
      #
      # Use this method if you need to persist a session, without providing it
      # any input.
      def create(attributes = {})
        INMEMORY_STORAGE[(model = new(attributes)).id] = model
      end
    end

    def initialize(attributes = {})
      attributes[:binding] ||= TOPLEVEL_BINDING
      @repl = WebConsole::REPL.new attributes[:binding]

      super(attributes)
      ensure_consequential_id!
      populate_repl_attributes!(initial: true)
    end

    def new_binding(binding)
      binding = binding
      @repl.binding = binding
    end

    # Saves the model into the in-memory storage.
    #
    # Returns false if the model is not valid (e.g. its missing input).
    def save(attributes = {})
      self.attributes = attributes if attributes.present?
      populate_repl_attributes!
      store!
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
      def ensure_consequential_id!
        synchronize do
          self.id = begin
            @@counter ||= 0
            @@counter  += 1
          end
        end
      end

      def populate_repl_attributes!(options = {})
        synchronize do
          # Don't send any input on the initial population so we don't bump up
          # the numbers in the dynamic prompts.
          self.output = @repl.send_input(input) unless options[:initial]
          self.prompt = @repl.prompt
        end
      end

      def store!
        synchronize { INMEMORY_STORAGE[id] = self }
      end
  end
end
