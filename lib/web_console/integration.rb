module WebConsole
  # Returns the Ruby bindings of Kernel#callers locations.
  #
  # The list of bindings here doesn't map 1 to 1 with Kernel#callers, as we
  # can't build Ruby bindings for C functions or the equivalent native
  # implementations in JRuby and Rubinius.
  #
  # This method needs to be overridden by every integration.
  def self.caller_bindings
    raise NotImplementedError
  end
end

class Exception
  # Returns an array of the exception backtrace locations bindings.
  #
  # The list won't map to the traces in #backtrace 1 to 1, because we can't
  # build bindings for every trace (C functions, for example).
  #
  # Every integration should the instance variable.
  def bindings
    @bindings || []
  end
end

case RUBY_ENGINE
when 'rbx'
  require 'web_console/integration/rubinius'
when 'ruby'
  require 'web_console/integration/cruby'
end
