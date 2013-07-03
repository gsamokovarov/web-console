require 'test_helper'

class IRBTest < ActiveSupport::TestCase
  test 'initialization with default binding' do
    assert_nothing_raised { WebConsole::REPL::IRB.new }
  end

  test 'sending input returns the result as output' do
    irb = WebConsole::REPL::IRB.new
    assert_equal "42\n", irb.send_input('foo = 42')
  end
end
