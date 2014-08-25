require 'simplecov'
SimpleCov.start 'rails'

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# This one is picked straight out of action_pack tests, so we can easily test
# with custom controllers for the tests.
SharedTestRoutes = ActionDispatch::Routing::RouteSet.new

module ActionDispatch
  module SharedRoutes
    def before_setup
      @routes = SharedTestRoutes
      super
    end
  end

  # Hold off drawing routes until all the possible controller classes
  # have been loaded.
  module DrawOnce
    class << self
      attr_accessor :drew
    end
    self.drew = false

    def before_setup
      super
      return if DrawOnce.drew

      SharedTestRoutes.draw do
        get ':controller(/:action)'
      end

      ActionDispatch::IntegrationTest.app.routes.draw do
        get ':controller(/:action)'
      end

      DrawOnce.drew = true
    end
  end
end

# rails-dom-testing assertions doesn't like the JavaScript we inject into the page.
module SilenceRailsDomTesting
  def assert_select(*)
    silence_warnings { super }
  end
end

ActiveSupport::TestCase.class_eval do
  include ActionDispatch::DrawOnce
end

ActionController::TestCase.class_eval do
  include SilenceRailsDomTesting
end

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end
