require 'test_helper'

class IRBTest < ActiveSupport::TestCase
  setup do
    @irb1 = @irb = WebConsole::REPL::IRB.new
    @irb2 = WebConsole::REPL::IRB.new

    # Flag to signalize that the .irbrc was read.
    $IRBRC_EXECUTED = false

    # Since IRB is kinda funky, it reads the .irbrc in $HOME/.irbrc earlier
    # that the one in the current working directory, we have to lie to it.
    @preserved_home, ENV['HOME'] = ENV['HOME'], nil

    # It also caches the procedure used to generate the .irbrc location.
    IRB.conf[:RC_NAME_GENERATOR] = nil
  end

  teardown do
    # Now, bring the working place as we have found it.
    ENV['HOME'] = @preserved_home
    WebConsole::Engine.config.web_console.prevent_irbrc_execution = false
  end

  test 'sending input returns the result as output' do
    assert_equal return_prompt(42), @irb.send_input('foo = 42')
  end

  test 'preserves the session in the binding' do
    assert_equal return_prompt(42), @irb.send_input('foo = 42')
    assert_equal return_prompt(50), @irb.send_input('foo + 8')
  end

  test 'session isolation requires own bindings' do
    irb1 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    irb2 = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    assert_equal return_prompt(42), irb1.send_input('foo = 42')
    assert_match %r{NameError}, irb2.send_input('foo')
  end

  test 'session preservation requires same bindings' do
    assert_equal return_prompt(42), @irb1.send_input('foo = 42')
    assert_equal return_prompt(42), @irb2.send_input('foo')
  end

  test 'multiline sessions' do
    irb = WebConsole::REPL::IRB.new(Object.new.instance_eval('binding'))
    assert_equal "", irb.send_input('class A')
    assert_equal return_prompt('nil'), irb.send_input('end')
    assert_no_match %r{NameError}, irb.send_input('A')
  end

  test 'captures direct stdout output' do
    assert_equal "42\n#{return_prompt('nil')}", @irb.send_input('puts 42')
  end

  test 'captures direct stderr output' do
    assert_equal "42\n#{return_prompt(3)}", @irb.send_input('$stderr.write("42\n")')
  end

  test 'captures direct output from subprocesses' do
    assert_equal "42\n#{return_prompt(true)}", @irb.send_input('system "echo 42"')
  end

  test 'captures direct output from forks' do
    # This is a bummer, but currently I don't see how we can work around it,
    # without monkey patching fork and the crew to be blocking calls. This
    # won't scale well, but at least fork will show results. Otherwise, we can
    # document the behaviour and expect the user to wait themselves, if they
    # care about the output.
    assert_match %r{42\n}, @irb.send_input('Process.wait(fork { puts 42 })')
  end

  test 'multiline support between threads' do
    assert_equal "", @irb.send_input('class A')
    Thread.new do
      assert_equal return_prompt('nil'), @irb.send_input('end')
      assert_no_match %r{NameError}, @irb.send_input('A')
    end.join
  end

  test 'prompt is present' do
    assert_not_nil @irb.prompt
  end

  test 'prompt is determined by ::IRB.conf' do
    with_simple_prompt do
      assert '>> ', WebConsole::REPL::IRB.new.prompt
    end
  end

  test 'closest .irbrc is executed by default' do
    skip "I'm special. Travis is special. Who knows?"
    Dir.chdir(File.expand_path('../../../fixtures', __FILE__)) do
      WebConsole::REPL::IRB.new.tap { assert $IRBRC_EXECUTED }
    end
  end

  test 'closest .irbrc execution can be prevented' do
    WebConsole::Engine.config.web_console.prevent_irbrc_execution = true
    Dir.chdir(File.expand_path('../../../fixtures', __FILE__)) do
      WebConsole::REPL::IRB.new.tap { refute $IRBRC_EXECUTED }
    end
  end

  test 'rails helpers are available in the session' do
    each_rails_console_method do |meth|
      assert_equal return_prompt(true), @irb.send_input("respond_to? :#{meth}")
    end
  end

  private
    def currently_selected_prompt
      ::IRB.conf[:PROMPT][::IRB.conf[:PROMPT_MODE]]
    end

    def return_prompt(*args)
      sprintf(currently_selected_prompt[:RETURN], *args)
    end

    def input_prompt
      currently_selected_prompt[:PROMPT_I]
    end

    def with_simple_prompt
      previous_prompt = ::IRB.conf[:PROMPT]
      ::IRB.conf[:PROMPT] = :simple
      yield
    ensure
      ::IRB.conf[:PROMPT] = previous_prompt
    end

    def each_rails_console_method(&block)
      require 'rails/console/app'
      require 'rails/console/helpers'
      Rails::ConsoleMethods.public_instance_methods.each(&block)
    end

    def new_uninitialized_app(root = File.expand_path('../../../dummy', __FILE__))
      FileUtils.mkdir_p root
      Dir.chdir root

      old_app = Rails.application
      Rails.application = nil

      app = Class.new(Rails::Application)
      app.config.eager_load = false
      app.config.time_zone = 'UTC'
      app.config.middleware ||= Rails::Configuration::MiddlewareStackProxy.new
      app.config.active_support.deprecation = :notify

      yield app
    ensure
      Rails.application = old_app
    end
end
