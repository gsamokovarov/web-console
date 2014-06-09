require 'test_helper'
require 'mocha'

class REPLTest < ActiveSupport::TestCase
  def test_extract_sources
    ex = StandardError.new
    wrapper = ActionDispatch::ExceptionWrapper.new({}, ex)
    ex.stubs(:backtrace).returns(["/test/controller.rb:9 in 'index'"])

    wrapper.expects(:source_fragment)
      .with('/test/controller.rb', 9)
      .returns('some code')

    assert_equal([{
      code: 'some code',
      file: '/test/controller.rb',
      line_number: 9
    }], wrapper.extract_sources)
  end
end
