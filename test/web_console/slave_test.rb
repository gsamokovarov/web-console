require 'stringio'
require 'test_helper'

class SlaveTest < ActiveSupport::TestCase
  setup do
    PTY.stubs(:spawn).returns([StringIO.new, StringIO.new, Random.rand(20000)])
    @slave = WebConsole::Slave.new
  end

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
    @slave.instance_variable_get(:@input).expects(:winsize=).with([32, 64])
    @slave.configure(height: 32, width: 64)
  end

  test '#configure only changes the @input dimentions if width is zero' do
    @slave.instance_variable_get(:@input).expects(:winsize=).never
    @slave.configure(height: 32, width: 0)
  end

  test '#configure only changes the @input dimentions if height is zero' do
    @slave.instance_variable_get(:@input).expects(:winsize=).never
    @slave.configure(height: 0, width: 64)
  end

  { dispose: :SIGTERM, dispose!: :SIGKILL }.each do |method, signal|
    test "##{method} sends #{signal} to the process and detaches it" do
      Process.expects(:kill).with(signal, @slave.pid)
      @slave.send(method)
    end
  end
end
