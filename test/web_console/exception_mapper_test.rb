# frozen_string_literal: true

require "test_helper"

module WebConsole
  class ExcetionMapperTest < ActiveSupport::TestCase
    test "#first tries to find the first application binding" do
      Rails.stubs(:root).returns Pathname(__FILE__).parent

      mapper = ExceptionMapper.new(External.exception)

      assert_equal __FILE__, mapper.first.eval("__FILE__")
    end

    test ".[] tries match the binding for trace index" do
      exception = External.exception
      mapper = ExceptionMapper.new(exception)

      last_index = exception.backtrace.count - 1
      file, line = exception.backtrace.last.split(":")

      assert_equal file, mapper[last_index].eval("__FILE__")
      assert_equal line.to_i, mapper[last_index].eval("__LINE__")
    end

    test ".[] fall backs to index if no trace can be found" do
      exception = External.exception
      mapper = ExceptionMapper.new(exception)

      unbound_index = exception.backtrace.count

      assert_nil mapper[unbound_index]
    end
  end
end
