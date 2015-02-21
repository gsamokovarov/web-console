require 'test_helper'

module WebConsole
  class IntegrationTest < ActiveSupport::TestCase
    test 'Exception#bindings returns all the bindings of where the error originated' do
      exc = FlatScenario.new.call

      assert_equal 4, exc.bindings.first.eval('__LINE__')
    end

    test 'Exception#bindings returns all the bindings for a custom error' do
      exc = CustomErrorScenario.new.call

      assert_equal 6, exc.bindings.first.eval('__LINE__')
    end

    test 'Exception#bindings returns all the bindings for a bad custom error' do
      exc = BadCustomErrorScenario.new.call

      assert_equal 11, exc.bindings.first.eval('__LINE__')
    end

    test 'Exception#bindings goes down the stack' do
      exc = BasicNestedScenario.new.call

      assert_equal 12, exc.bindings.first.eval('__LINE__')
    end

    test 'Exception#bindings inside of an eval' do
      exc = EvalNestedScenario.new.call

      assert_equal 12, exc.bindings.first.eval('__LINE__')
    end

    test "re-raising doesn't lose Exception#bindings information" do
      exc = ReraisedScenario.new.call

      assert_equal 4, exc.bindings.first.eval('__LINE__')
    end

    test 'Exception#bindings is empty when exception is still not raised' do
      exc = RuntimeError.new

      assert_equal [], exc.bindings
    end
  end
end
