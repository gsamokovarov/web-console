# frozen_string_literal: true

require "test_helper"

module WebConsole
  class SessionTest < ActiveSupport::TestCase
    class ValueAwareError < StandardError
      def self.raise(value)
        ::Kernel.raise self, value
      rescue => exc
        exc
      end

      attr_reader :value

      def initialize(value)
        @value = value
      end
    end

    setup do
      Session.inmemory_storage.clear
      @session = Session.new([binding])
    end

    test "returns nil when a session is not found" do
      assert_nil Session.find("nonexistent session")
    end

    test "find returns a persisted object" do
      assert_equal @session, Session.find(@session.id)
    end

    test "can evaluate code in the currently selected binding" do
      assert_equal "=> 42\n", @session.eval("40 + 2")
    end

    test "use first binding if no application bindings" do
      binding = Object.new.instance_eval do
        def eval(string)
          case string
          when "__FILE__" then framework
          when "called?" then "yes"
          end
        end

        self
      end

      session = Session.new([binding])
      assert_equal session.eval("called?"), "=> \"yes\"\n"
    end

    test "#from can create session from a single binding" do
      value, saved_binding = __LINE__, binding
      Thread.current[:__web_console_binding] = saved_binding

      session = Session.from(__web_console_binding: saved_binding)

      assert_equal "=> #{value}\n", session.eval("value")
    end

    test "#from can create session from an exception" do
      value = __LINE__
      exc = ValueAwareError.raise(value)

      session = Session.from(__web_console_exception: exc)

      assert_equal "=> #{exc.value}\n", session.eval("value")
    end

    test "#from can switch to bindings" do
      value = __LINE__
      exc = ValueAwareError.raise(value)

      session = Session.from(__web_console_exception: exc)
      session.switch_binding_to(1)

      assert_equal "=> #{value}\n", session.eval("value")
    end

    test "#from prioritizes exceptions over bindings" do
      exc = ValueAwareError.raise(42)

      session = Session.from(__web_console_exception: exc, __web_console_binding: binding)

      assert_equal "=> WebConsole::SessionTest::ValueAwareError\n", session.eval("self")
    end
  end
end
