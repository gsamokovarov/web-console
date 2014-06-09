require 'test_helper'

module ActionDispatch
  class ExceptionWrapperTest < ActiveSupport::TestCase
    class TestError < StandardError
      attr_reader :backtrace

      def initialize(*backtrace)
        @backtrace = backtrace
      end
    end

    test '#extract_sources fetches source fragments for every backtrace' do
      exc = TestError.new("/test/controller.rb:9 in 'index'")

      wrapper = ExceptionWrapper.new({}, exc)
      wrapper.expects(:source_fragment).with('/test/controller.rb', 9).returns('some code')

      assert_equal [{
        code: 'some code',
        file: '/test/controller.rb',
        line_number: 9
      }], wrapper.extract_sources
    end
  end
end
