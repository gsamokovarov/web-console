require 'test_helper'

class IRBTest < ActiveSupport::TestCase
  setup do
    @irb1 = @irb = WebConsole::REPL::IRB.new
    @irb2 = WebConsole::REPL::IRB.new
  end

  test 'sending input returns the result as output' do
    assert_equal sprintf(return_prompt, "42"), @irb.send_input('foo = 42')
  end

  test 'preserves the session in the binding' do
    assert_equal sprintf(return_prompt, "42"), @irb.send_input('foo = 42')
    assert_equal sprintf(return_prompt, "50"), @irb.send_input('foo + 8')
  end

  test 'session isolation requires own bindings' do
    irb1 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    irb2 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    assert_equal sprintf(return_prompt, "42"), irb1.send_input('foo = 42')
    assert_match undefined_var_or_method('foo'), irb2.send_input('foo')
  end

  test 'session preservation requires same bindings' do
    assert_equal sprintf(return_prompt, "42"), @irb1.send_input('foo = 42')
    assert_equal sprintf(return_prompt, "42"), @irb2.send_input('foo')
  end

  test 'multiline sessions' do
    irb = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    assert_equal "", irb.send_input('class A')
    assert_equal sprintf(return_prompt, 'nil'), irb.send_input('end')
    assert_no_match uninitialized_constant('A'), irb.send_input('A')
  end

  test 'captures direct stdout output' do
    assert_equal "42\n#{sprintf(return_prompt, 'nil')}", @irb.send_input('puts 42')
  end

  test 'captures direct stderr output' do
    assert_equal "42\n#{sprintf(return_prompt, '3')}", @irb.send_input('$stderr.write("42\n")')
  end

  test 'captures direct output from subprocesses' do
    assert_equal "42\n#{sprintf(return_prompt, 'true')}", @irb.send_input('system "echo 42"')
  end

  test 'captures direct output from forks' do
    # This is a bummer, but currently I don't see how we can work around it.
    # Since we are redirecting the output streams only for the duration of the
    # send_input execution, childs that print to stdout, may miss this time.
    assert_equal "42\n#{sprintf(return_prompt, '2')}", @irb.send_input('Process.wait fork { puts 42 };')
  end

  test 'prompt is the globally selected one' do
    assert_equal input_prompt, @irb.prompt
  end

  test 'prompt is present' do
    assert_not_nil @irb.prompt
  end

  test 'rails helpers are available in the session' do
    each_rails_console_method do |meth|
      assert_no_match undefined_var_or_method(meth), @irb.send_input("respond_to? :#{meth}")
    end
  end

  private
    def currently_selected_prompt
      ::IRB.conf[:PROMPT][::IRB.conf[:PROMPT_MODE]]
    end

    def return_prompt
      currently_selected_prompt[:RETURN]
    end

    def input_prompt
      currently_selected_prompt[:PROMPT_I]
    end

    def undefined_var_or_method(name)
      %r{undefined local variable or method `#{name}'}
    end

    def uninitialized_constant(name)
      %r{uninitialized constant #{name}}
    end

    def each_rails_console_method(&block)
      require 'rails/console/app'
      require 'rails/console/helpers'
      Rails::ConsoleMethods.public_instance_methods.each(&block)
    end
end
