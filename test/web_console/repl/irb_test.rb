require 'test_helper'

class IRBTest < ActiveSupport::TestCase
  test 'initialization with default binding' do
    assert_nothing_raised { WebConsole::REPL::IRB.new }
  end

  test 'sending input returns the result as output' do
    irb = WebConsole::REPL::IRB.new
    assert_equal sprintf(return_prompt, "42\n"), irb.send_input('foo = 42')
  end

  test 'preserves the session in the binding' do
    irb = WebConsole::REPL::IRB.new
    assert_equal sprintf(return_prompt, "42\n"), irb.send_input('foo = 42')
    assert_equal sprintf(return_prompt, "50\n"), irb.send_input('foo + 8')
  end

  private
    def return_prompt
      ::IRB.conf[:PROMPT][::IRB.conf[:PROMPT_MODE]][:RETURN]
    end
end
