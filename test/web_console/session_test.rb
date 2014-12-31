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
      Session::INMEMORY_STORAGE.clear
      @session = Session.new TOPLEVEL_BINDING
    end

    test 'raises Session::NotFound on not found sessions' do
      assert_raises(Session::NotFound) { Session.find("nonexistent session") }
    end

    test 'find returns a persisted object' do
      assert_equal @session, Session.find(@session.id)
    end

    test 'not found exceptions are JSON serializable' do
      exception = assert_raises(Session::NotFound) { Session.find("nonexistent session") }
      assert_equal '{"error":"Session unavailable"}', exception.to_json
    end

    test 'can evaluate code in the currently selected binding' do
      assert_equal "=> 42\n", @session.eval('40 + 2')
    end

    test 'can create session from a single binding' do
      saved_line, saved_binding = __LINE__, binding
      session = Session.from_binding(saved_binding)

      assert_equal "=> #{saved_line}\n", session.eval('__LINE__')
    end

    test 'can create session from an exception' do
      exc = LineAwareError.raise
      session = Session.from_exception(exc)

      assert_equal "=> #{exc.line}\n", session.eval('__LINE__')
    end

    test 'is aware if it has multiple bindings' do
      exc = LineAwareError.raise
      session = Session.from_exception(exc)

      assert session.for_error_page?
    end

    test 'can switch to bindings' do
      exc, saved_line = LineAwareError.raise, __LINE__

      session = Session.from_exception(exc)
      session.switch_binding_to(1)

      assert_equal "=> #{saved_line}\n", session.eval('__LINE__')
    end
  end
end
