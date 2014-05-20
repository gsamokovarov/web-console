module WebConsole
  # @private
  class Railtie < Rails::Railtie
    initializer "web_console.configure_rails_initialization" do
      WebConsole.logger = Rails.logger
      WebConsole.application_root = Rails.root.to_s
      insert_middleware
    end

    def insert_middleware
      if defined? ActionDispatch::DebugExceptions
        app.middleware.insert_after ActionDispatch::DebugExceptions, WebConsole::Middleware
      else
        app.middleware.use WebConsole::Middleware
      end
    end

    def app
      Rails.application
    end
  end
end
