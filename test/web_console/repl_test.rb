require 'test_helper'

class REPLTest < ActiveSupport::TestCase
  setup do
    @repl1 = @repl = WebConsole::REPL.new
    @repl2 = WebConsole::REPL.new
  end

  test 'sending input returns the result as output' do
    assert_equal "=> 42\n", @repl.send_input('foo = 42')
  end

  test 'preserves the session in the binding' do
    assert_equal "=> 42\n", @repl.send_input('foo = 42')
    assert_equal "=> 50\n", @repl.send_input('foo + 8')
  end

  # test 'session isolation requires own bindings' do
  #   dummy1 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
  #   dummy2 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
  #   assert_equal "=> 42\n", dummy1.send_input('foo = 42')
  #   assert_match %r{NameError}, dummy2.send_input('foo')
  # end

  test 'session preservation requires same bindings' do
    assert_equal "=> 42\n", @repl1.send_input('foo = 42')
    assert_equal "=> 42\n", @repl2.send_input('foo')
  end

  test 'captures stdout output' do
    assert_equal "=> nil\n", @repl.send_input('puts 42')
  end

  test 'captures stderr output' do
    assert_equal "=> 3\n", @repl.send_input('$stderr.write("42\n")')
  end

  test 'prompt is present' do
    assert_not_nil @repl.prompt
  end
end
