require 'test_helper'

module WebConsole
  class SessionTest < ActiveSupport::TestCase
    class LineAwareError < StandardError
      def self.raise
        ::Kernel.raise new(__LINE__)
      rescue => exc
        exc
      end

      attr_reader :line

      def initialize(line)
        @line = line
      end
    end

    setup do
      Rails.stubs(:root).returns Pathname(__FILE__).parent
      Session.inmemory_storage.clear
      @session = Session.new(binding)
    end

    test 'returns nil when a session is not found' do
      assert_nil Session.find("nonexistent session")
    end

    test 'find returns a persisted object' do
      assert_equal @session, Session.find(@session.id)
    end

    test 'can evaluate code in the currently selected binding' do
      assert_equal "=> 42\n", @session.eval('40 + 2')
    end

    test 'find first binding of the rails app' do
      session = Session.new(External.exception.bindings)
      assert_equal session.eval('__FILE__'), "=> \"#{__FILE__}\"\n"
    end

    test 'use first binding if no application bindings' do
      binding = Object.new
      binding.expects(:eval).with('__FILE__').returns 'framework'
      binding.expects(:eval).with('called?').returns 'yes'

      session = Session.new(binding)
      assert_equal session.eval('called?'), "=> \"yes\"\n"
    end

    test '#from can create session from a single binding' do
      saved_line, saved_binding = __LINE__, binding
      Thread.current[:__web_console_binding] = saved_binding

      session = Session.from(__web_console_binding: saved_binding)

      assert_equal "=> #{saved_line}\n", session.eval('__LINE__')
    end

    test '#from can create session from an exception' do
      exc = LineAwareError.raise

      session = Session.from(__web_console_exception: exc)

      assert_equal "=> #{exc.line}\n", session.eval('__LINE__')
    end

    test '#from can switch to bindings' do
      exc, saved_line = LineAwareError.raise, __LINE__

      session = Session.from(__web_console_exception: exc)
      session.switch_binding_to(1)

      assert_equal "=> #{saved_line}\n", session.eval('__LINE__')
    end

    test '#from prioritizes exceptions over bindings' do
      exc, saved_line = LineAwareError.raise, __LINE__

      session = Session.from(__web_console_exception: exc, __web_console_binding: binding)
      session.switch_binding_to(1)

      assert_equal "=> #{saved_line}\n", session.eval('__LINE__')
    end
  end
end
