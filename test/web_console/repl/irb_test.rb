require 'test_helper'

class IRBTest < ActiveSupport::TestCase
  test 'initialization with default binding' do
    assert_nothing_raised { WebConsole::REPL::IRB.new }
  end
end
