require 'test_helper'

class ExceptionExtensionTest < ActiveSupport::TestCase
  class TestError < StandardError
  end

  test 'should store binding trace if binding_of_caller is available' do
    begin
      test = "Test"
      raise TestError
    rescue TestError => e
      assert e.__web_console_bindings_stack.length > 0
      assert e.__web_console_bindings_stack[0].eval("test") == "Test"
    end
  end
end
