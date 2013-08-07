require 'test_helper'

class REPLTest < ActiveSupport::TestCase
  setup do
    @dummy1 = @dummy = WebConsole::REPL::Dummy.new
    @dummy2 = WebConsole::REPL::Dummy.new
  end

  test 'sending input returns the result as output' do
    assert_equal "=> 42\n", @dummy.send_input('foo = 42')
  end

  test 'preserves the session in the binding' do
    assert_equal "=> 42\n", @dummy.send_input('foo = 42')
    assert_equal "=> 50\n", @dummy.send_input('foo + 8')
  end

  test 'session isolation requires own bindings' do
    dummy1 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    dummy2 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    assert_equal "=> 42\n", dummy1.send_input('foo = 42')
    assert_match %r{NameError}, dummy2.send_input('foo')
  end

  test 'session preservation requires same bindings' do
    assert_equal "=> 42\n", @dummy1.send_input('foo = 42')
    assert_equal "=> 42\n", @dummy2.send_input('foo')
  end

  test 'captures stdout output' do
    assert_equal "42\n=> nil\n", @dummy.send_input('puts 42')
  end

  test 'captures stderr output' do
    assert_equal "42\n=> 3\n", @dummy.send_input('$stderr.write("42\n")')
  end

  test 'prompt is present' do
    assert_not_nil @dummy.prompt
  end

  test 'rails helpers are available in the session' do
    each_rails_console_method do |meth|
      assert_equal "=> true\n", @dummy.send_input("respond_to? :#{meth}")
    end
  end

  private

    def each_rails_console_method(&block)
      require 'rails/console/app'
      require 'rails/console/helpers'
      Rails::ConsoleMethods.public_instance_methods.each(&block)
    end
end
