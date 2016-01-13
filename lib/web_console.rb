require 'active_support/lazy_load_hooks'
require 'active_support/logger'

require 'web_console/integration'
require 'web_console/railtie'
require 'web_console/errors'
require 'web_console/template'
require 'web_console/middleware'
require 'web_console/whitelist'
require 'web_console/request'

module WebConsole
  autoload :View, 'web_console/view'
  autoload :Helper, 'web_console/helper'
  autoload :Evaluator, 'web_console/evaluator'
  autoload :Session, 'web_console/session'
  autoload :Response, 'web_console/response'
  autoload :WhinyRequest, 'web_console/whiny_request'

  mattr_accessor :logger
  @@logger = ActiveSupport::Logger.new($stderr)

  ActiveSupport.run_load_hooks(:web_console, self)
end
