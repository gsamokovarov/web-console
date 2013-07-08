require 'test_helper'

class IRBTest < ActiveSupport::TestCase
  setup do
    @irb1 = @irb = WebConsole::REPL::IRB.new
    @irb2 = WebConsole::REPL::IRB.new
  end

  test 'sending input returns the result as output' do
    assert_equal sprintf(return_prompt, "42\n"), @irb.send_input('foo = 42')
  end

  test 'preserves the session in the binding' do
    assert_equal sprintf(return_prompt, "42\n"), @irb.send_input('foo = 42')
    assert_equal sprintf(return_prompt, "50\n"), @irb.send_input('foo + 8')
  end

  test 'session isolation requires own bindings' do
    irb1 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    irb2 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    assert_equal sprintf(return_prompt, "42\n"), irb1.send_input('foo = 42')
    assert_match undefined_var_or_method('foo'), irb2.send_input('foo')
  end

  test 'session preservation requires same bindings' do
    assert_equal sprintf(return_prompt, "42\n"), @irb1.send_input('foo = 42')
    assert_equal sprintf(return_prompt, "42\n"), @irb2.send_input('foo')
  end

  test 'multiline sessions' do
    irb = WebConsole::REPL::IRB.new(Object.new.instance_eval { binding })
    irb.send('class A')
    irb.send('end')
    assert_equal sprintf(return_prompt, "42\n"), irb.send_input('A')
  end

  test 'prompt is the globally selected one' do
    assert_equal input_prompt, @irb.prompt
  end

  test "prompt isn't nil" do
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

    def each_rails_console_method(&block)
      require 'rails/console/app'
      require 'rails/console/helpers'
      Rails::ConsoleMethods.public_instance_methods.each(&block)
    end
end
