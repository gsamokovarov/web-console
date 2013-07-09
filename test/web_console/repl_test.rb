require 'test_helper'

class REPLTest < ActiveSupport::TestCase
  test 'standalone adapter registration' do
    WebConsole::REPL::register_adapter adapter = Class.new, standalone: true
    assert_equal adapter, WebConsole::REPL::adapters[adapter]
  end

  test 'fallback for unsupported config.console' do
    app_mock = Class.new do
      define_singleton_method(:config) { OpenStruct.new(console: nil) }
    end
    assert_equal WebConsole::REPL::Dummy, WebConsole::REPL.default(app_mock)
  end
end
