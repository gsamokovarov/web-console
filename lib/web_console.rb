require 'rails'
require 'active_support/rails'
require 'web_console/version'

module WebConsole
  extend ActiveSupport::Autoload

  autoload :Engine
end
