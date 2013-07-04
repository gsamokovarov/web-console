module WebConsole
  module REPL
    extend self

    # Registry of REPL implementations mapped to their correspondent adapter
    # classes.
    #
    # Don't manually alter the registry. Use WebConsole::REPL.register_adapter
    # for adding entries.
    def adapters
      @adapters ||= {}
    end

    # Register an adapter into the adapters registry.
    #
    # Registration maps and adapter class to an existing REPL implementation,
    # that we call an adaptee constant. If the adaptee constant is not given,
    # it is automatically derived from the adapter class name.
    #
    # For example, adapter named +WebConsole::REPL::IRB+ will derive the
    # adaptee constant to +::IRB+.
    def register_adapter(adapter_class, adaptee_constant = nil)
      adaptee_constant ||= derive_adaptee_constant_from(adapter_class)
      adapters[adaptee_constant] = adapter_class
    end

    # Get the default adapter for the given application.
    #
    # By default the application will be Rails.application and the adapter
    # will be chosen from Rails.application.config.console.
    def default(app = Rails.application)
      adapters[app.config.console]
    end

    private
      def derive_adaptee_constant_from(cls, suffix = 'REPL')
        "::#{cls.name.split('::').last.gsub(/#{suffix}$/i, '')}".constantize
      end
  end
end

Dir["#{File.dirname(__FILE__)}/repl/*.rb"].each do |implementation|
  require implementation
end
