require "web_console/view_helpers"

module WebConsole
  class Railtie < Rails::Railtie
    initializer "web_console.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
      ActionController::Base.prepend_view_path File.dirname(__FILE__) + '/../action_dispatch/templates'
    end
  end
end
