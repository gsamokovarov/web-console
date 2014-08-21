module WebConsole
  class REPLSession
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
        INMEMORY_STORAGE[id.to_i] or raise NotFound, 'Session unavailable'
      end

      # Creates an already persisted console session.
      #
      # Use this method if you need to persist a session, without providing it
      # any input.
      def create(attributes = {})
        INMEMORY_STORAGE[(model = new(attributes)).id] = model
      end
    end

    def initialize(attributes = {})
      self.attributes = attributes
      ensure_consequential_id!
      populate_repl_attributes!(initial: true)
    end

    def binding=(binding)
      @binding = binding
      @repl = WebConsole::REPL.new(binding)
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
        self.id = begin
          @@counter ||= 0
          @@counter  += 1
        end
      end

      def populate_repl_attributes!(options = {})
        # Don't send any input on the initial population so we don't bump up
        # the numbers in the dynamic prompts.
        self.output = @repl.send_input(input) unless options[:initial]
        self.prompt = @repl.prompt
      end

      def store!
        INMEMORY_STORAGE[id] = self
      end
  end
end
