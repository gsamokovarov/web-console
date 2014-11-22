require 'binding_of_caller'

require 'active_support/lazy_load_hooks'

require 'web_console/core_ext/exception'
require 'web_console/engine'
require 'web_console/repl'
require 'web_console/repl_session'
require 'web_console/unsupported_platforms'
require 'web_console/middleware'

module WebConsole
  # Shortcut the +WebConsole::Engine.config.web_console+.
  def self.config
    Engine.config.web_console
  end

  ActiveSupport.run_load_hooks(:web_console, self)
end
