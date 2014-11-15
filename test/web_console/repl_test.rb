require 'test_helper'

class REPLTest < ActiveSupport::TestCase
  class TestError < StandardError
    def backtrace
      [
        "/web-console/lib/web_console/repl.rb:16:in `eval'",
        "/web-console/lib/web_console/repl.rb:16:in `send_input'"
      ]
    end
  end

  class BadlyDefinedError < StandardError
    def backtrace
      nil
    end
  end

  setup do
    @repl1 = @repl = WebConsole::REPL.new
    @repl2         = WebConsole::REPL.new
  end

  test 'sending input returns the result as output' do
    assert_equal "=> 42\n", @repl.send_input('foo = 42')
  end

  test 'preserves the session in the binding' do
    assert_equal "=> 42\n", @repl.send_input('foo = 42')
    assert_equal "=> 50\n", @repl.send_input('foo + 8')
  end

  test 'session preservation requires same bindings' do
    assert_equal "=> 42\n", @repl1.send_input('foo = 42')
    assert_equal "=> 42\n", @repl2.send_input('foo')
  end

  test 'prompt is present' do
    assert_not_nil @repl.prompt
  end

  test 'formats exceptions similarly to IRB' do
    repl = WebConsole::REPL.new(binding)

    assert_equal <<-END.strip_heredoc, repl.send_input("raise TestError, 'panic'")
      #{TestError.name}: panic
      \tfrom /web-console/lib/web_console/repl.rb:16:in `eval'
      \tfrom /web-console/lib/web_console/repl.rb:16:in `send_input'
    END
  end

  test 'no backtrace is shown if exception backtrace is blank' do
    repl = WebConsole::REPL.new(binding)

    assert_equal <<-END.strip_heredoc, repl.send_input("raise BadlyDefinedError")
      #{BadlyDefinedError.name}: #{BadlyDefinedError.name}
    END
  end

  test 'WebConsole::REPL callers are cleaned up of unneeded backtraces' do
    # Those have to be on the same line to get the same trace.
    repl, trace = WebConsole::REPL.new(binding), current_trace

    assert_equal <<-END.strip_heredoc, repl.send_input("raise")
      RuntimeError: 
      \tfrom #{trace}
    END
  end

  private

    def current_trace
      caller.first
    end
end
