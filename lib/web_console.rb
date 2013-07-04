require 'active_support/lazy_load_hooks'
require 'web_console/engine'
require 'web_console/repl'

module WebConsole
  ActiveSupport.run_load_hooks(:web_console, self)
end
