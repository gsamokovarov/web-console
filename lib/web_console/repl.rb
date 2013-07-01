module WebConsole
  module REPL
    class << self
      # The adapters registry.
      #
      # Don't manually alter the registry, use +WebConsole::REPL.register_adapter+.
      def adapters
        @adapters ||= {}
      end

      # Register an adapter into the adapters registry.
      #
      # Registration maps and adapter class to an existing REPL implementation,
      # that we call an adaptee constant. If the adaptee constant is not given,
      # it is automatically derived from the adapter class name.
      #
      # For example, adapter named `WebConsole::REPL::IRB` will derive the
      # adaptee constant to `::IRB`.
      def register_adapter(adapter_class, adaptee_constant = nil)
        adaptee_constant ||= derive_adaptee_constant_from(adapter_class)
        adapters[adaptee_constant] = adapter_class
      end

      # Get the default adapter for the given application.
      #
      # By default the application will be Rails.application and the adapter
      # will be chosen from config.console.
      def default(app = Rails.application)
        adapters[app.config.console]
      end

      private
        def derive_adaptee_constant_from(adapter_class, suffix = 'REPL')
          "::#{adapter_class.name.split('::').last.gsub(/#{suffix}$/i, '')}".constantize
        end
    end
  end
end

Dir["#{File.dirname(__FILE__)}/repl/*.rb"].each do |implementation|
  require implementation
end
