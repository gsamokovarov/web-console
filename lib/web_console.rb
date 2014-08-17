require 'active_support/lazy_load_hooks'
require 'action_dispatch/exception_wrapper'
require 'action_dispatch/debug_exceptions'

require "web_console/view_helpers"
require 'web_console/colors'
require 'web_console/engine'
require 'web_console/repl'
require 'web_console/repl_session'
require 'web_console/slave'

module WebConsole
  class << self
    attr_accessor :binding_of_caller_available

    alias_method :binding_of_caller_available?, :binding_of_caller_available

    # Shortcut the +WebConsole::Engine.config.web_console+.
    def config
      Engine.config.web_console
    end
  end

  ActiveSupport.run_load_hooks(:web_console, self)
end

begin
  require 'binding_of_caller'
  WebConsole.binding_of_caller_available = true
rescue LoadError
  WebConsole.binding_of_caller_available = false
end

require 'web_console/exception_extension'
