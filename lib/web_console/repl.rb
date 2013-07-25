require 'active_support/core_ext/string/inflections'

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
    #
    # If a block is given, it would be evaluated right after the adapter
    # registration.
    def register_adapter(adapter_class, adaptee_constant = nil, options = {})
      if adaptee_constant.is_a?(Hash)
        options          = adaptee_constant
        adaptee_constant = nil
      end
      adaptee_constant   = adapter_class if options[:standalone]
      adaptee_constant ||= derive_adaptee_constant_from(adapter_class)
      adapters[adaptee_constant] = adapter_class
      yield if block_given?
    end

    # Get the default adapter for the given application.
    #
    # By default the application will be Rails.application and the adapter
    # will be chosen from Rails.application.config.console.
    #
    # If no suitible adapter is found for the configured Rails console, a dummy
    # adapter will be used. You can evaluate code in it, but it won't support
    # any advanced features, like multiline code evaluation.
    def default(app = Rails.application)
      adapters[app.config.console || ::IRB] || adapters[Dummy]
    end

    private
      def derive_adaptee_constant_from(cls, suffix = 'REPL')
        "::#{cls.name.split('::').last.gsub(/#{suffix}$/i, '')}".constantize
      end
  end
end

# Require the builtin adapters.
require 'web_console/repl/irb'
require 'web_console/repl/dummy'
