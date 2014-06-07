require 'rails/engine'

module WebConsole
  class Engine < ::Rails::Engine
    isolate_namespace WebConsole
  end
end
