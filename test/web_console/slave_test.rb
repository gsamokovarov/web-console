require 'test_helper'

class SlaveTest < ActiveSupport::TestCase
  include Process

  setup    { @slave = WebConsole::Slave.new }
  teardown { @slave.dispose.try(:join) }

  test '#pending_output returns nil on no pending output' do
    @slave.stubs(:pending_output?).returns(false)
    assert_nil @slave.pending_output
  end

  test '#pending_output returns a string with the current output' do
    @slave.stubs(:pending_output?).returns(true)
    @slave.instance_variable_get(:@output).stubs(:read_nonblock).returns('foo', nil)
    assert_equal 'foo', @slave.pending_output
  end

  test '#pending_output always encodes output in UTF-8' do
    @slave.stubs(:pending_output?).returns(true)
    @slave.instance_variable_get(:@output).stubs(:read_nonblock).returns('foo', nil)
    assert_equal Encoding::UTF_8, @slave.pending_output.encoding
  end

  test '#configure changes @input dimentions' do
    @slave.configure(height: 32, width: 64)
    assert_equal @slave.instance_variable_get(:@input).winsize, [32, 64]
  end

  { dispose: :SIGTERM, dispose!: :SIGKILL }.each do |method, signal|
    test "##{method} sends #{signal} to the process and detaches it" do
      waiting_thread = @slave.send(method).join
      assert_raises(Errno::ECHILD, SystemCallError) { wait(@slave.pid) }
      # JRuby waiting thread value will be just the PID.
      assert_match Regexp.new(@slave.pid.to_s), waiting_thread.value.to_s
    end
  end

  test '#pid keeps a reference to the process pid' do
    assert_nothing_raised { wait(@slave.pid, WNOHANG) }
  end
end
