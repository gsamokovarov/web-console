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

  test 'session isolation requires own bindings' do
    irb1 = WebConsole::REPL::IRB.new(Object.new.instance_eval { binding })
    irb2 = WebConsole::REPL::IRB.new(Object.new.instance_eval { binding })
    assert_equal sprintf(return_prompt, "42\n"), irb1.send_input('foo = 42')
    assert_match %r{undefined local variable or method `foo'}, irb2.send_input('foo')
  end

  test 'session preservation requires same bindings' do
    irb1 = WebConsole::REPL::IRB.new
    irb2 = WebConsole::REPL::IRB.new
    assert_equal sprintf(return_prompt, "42\n"), irb1.send_input('foo = 42')
    assert_equal sprintf(return_prompt, "42\n"), irb2.send_input('foo')
  end

  private
    def return_prompt
      ::IRB.conf[:PROMPT][::IRB.conf[:PROMPT_MODE]][:RETURN]
    end
end
