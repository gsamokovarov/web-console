require 'test_helper'

module WebConsole
  class ExceptionTest < ActiveSupport::TestCase
    class TestScenarionWithNestedCalls
      def call
        raise_an_error
      rescue => exc
        exc
      end

      private

        def raise_an_error
          unused_local_variable = 42
          raise
        end
    end

    CustomError = Class.new(StandardError)

    test '#bindings all the bindings of where the error originated' do
      begin
        unused_local_variable = "Test"
        raise
      rescue => exc
        assert_equal 'Test', exc.bindings.first.eval('unused_local_variable')
      end
    end

    test '#bindings all the bindings of where the error originated from a custom error' do
      begin
        unused_local_variable = "Test"
        raise CustomError
      rescue => exc
        assert_equal 'Test', exc.bindings.first.eval('unused_local_variable')
      end
    end

    test '#bindings goes down the stack' do
      exc = TestScenarionWithNestedCalls.new.call

      assert_equal 42, exc.bindings.first.eval('unused_local_variable')
    end
  end
end
