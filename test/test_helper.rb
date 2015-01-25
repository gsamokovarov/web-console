case RUBY_ENGINE
when 'ruby', 'rbx'
  require 'simplecov'
  SimpleCov.start 'rails'
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# rails-dom-testing assertions doesn't like the JavaScript we inject into the page.
module SilenceRailsDomTesting
  def assert_select(*)
    silence_warnings { super }
  end
end

# Allows you to specify test to run only on specific Ruby platforms.
#
# Example:
#
#   test 'CRuby specific feature', only: :ruby
#   test 'CRuby and JRuby specific feature', only: %w(ruby jruby)
#
# If the :only option isn't present, the test is defined for all the platforms.
module PlatformSpecificTestMacro
  def test(name, options = {})
    platforms = Array(options[:only]).map(&:to_s)

    if platforms.blank? || RUBY_ENGINE.in?(platforms)
      super(name)
    end
  end
end

ActiveSupport::TestCase.class_eval do
  extend PlatformSpecificTestMacro
end

ActionDispatch::IntegrationTest.class_eval do
  include SilenceRailsDomTesting
end

# A copy of Kernel#capture in active_support/core_ext/kernel/reporting.rb as
# its getting deprecated past 4.2. Its not thread safe, but I don't need it to
# be in the tests
def capture(stream)
  stream = stream.to_s
  captured_stream = Tempfile.new(stream)
  stream_io = eval("$#{stream}")
  origin_stream = stream_io.dup
  stream_io.reopen(captured_stream)

  yield

  stream_io.rewind
  return captured_stream.read
ensure
  captured_stream.close
  captured_stream.unlink
  stream_io.reopen(origin_stream)
end

alias silence capture

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

require 'mocha/mini_test'
