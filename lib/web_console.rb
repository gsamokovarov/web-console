require 'active_support/lazy_load_hooks'
require 'web_console/repl'
require 'web_console/repl_session'
require 'action_dispatch/exception_wrapper'
require 'action_dispatch/debug_exceptions'

module WebConsole
  class << self
    attr_accessor :binding_of_caller_available

    alias_method :binding_of_caller_available?, :binding_of_caller_available
  end
end

begin
  require 'binding_of_caller'
  WebConsole.binding_of_caller_available = true
rescue LoadError => e
  WebConsole.binding_of_caller_available = false
end

require 'web_console/exception_extension'
require 'web_console/railtie'
