require 'binding_of_caller'

require 'active_support/lazy_load_hooks'

require 'web_console/core_ext/exception'
require 'web_console/engine'
require 'web_console/errors'
require 'web_console/helper'
require 'web_console/evaluator'
require 'web_console/session'
require 'web_console/template'
require 'web_console/unsupported_platforms'
require 'web_console/middleware'
require 'web_console/whitelist'
require 'web_console/request'

module WebConsole
  ActiveSupport.run_load_hooks(:web_console, self)
end
