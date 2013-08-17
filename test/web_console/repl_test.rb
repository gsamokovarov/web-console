require 'test_helper'

class REPLTest < ActiveSupport::TestCase
  include Process

  setup    { @repl = WebConsole::REPL.new }
  teardown { @repl.dispose.try(:join) }

  test '#pending_output returns nil on no pending output' do
    @repl.stubs(:pending_output?).returns(false)
    assert_nil @repl.pending_output
  end

  test '#pending_output returns a string with the current output' do
    @repl.stubs(:pending_output?).returns(true)
    @repl.instance_variable_get(:@output).stubs(:read_nonblock).returns('foo', nil)
    assert_equal 'foo', @repl.pending_output
  end

  { dispose: :SIGTERM, dispose!: :SIGKILL }.each do |method, signal|
    test "##{method} sends #{signal} to the process and detaches it" do
      waiting_thread = @repl.send(method).join
      assert_raises(Errno::ECHILD, SystemCallError) { wait(@repl.pid) }
      assert_match Regexp.new(signal.to_s), waiting_thread.value.to_s
    end
  end

  test '#pid keeps a reference to the process pid' do
    assert_nothing_raised { wait(@repl.pid, WNOHANG) }
  end
end
