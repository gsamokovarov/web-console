require 'active_support/lazy_load_hooks'
require 'web_console/engine'
require 'web_console/repl'

module WebConsole
  # Shortcut the +WebConsole::Engine.config.web_console+.
  def self.config
    Engine.config.web_console
  end

  ActiveSupport.run_load_hooks(:web_console, self)
end
