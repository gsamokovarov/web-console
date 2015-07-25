require 'test_helper'

module WebConsole
  class ResponseTest < ActiveSupport::TestCase
    test '#acceptable_content_type? is truthy if response format is HTML' do
      res = response('Content-Type' => 'text/html; charset=utf-8')

      assert res.acceptable_content_type?
    end

    test '#acceptable_content_type? is falsy if response format is not HTML' do
      res = response('Content-Type' => 'application/json; charset=utf-8')

      refute res.acceptable_content_type?
    end

    test '#acceptable_content_type? logs out to stderr if falsy' do
      assert_output_to_stderr do
        res = response({ 'Content-Type' => 'application/json; charset=utf-8' }, default_logger)
        res.acceptable_content_type?
      end
    end

    test '#acceptable_content_type? does not log out to stderr if truthy' do
      assert_not_output_to_stderr do
        res = response({ 'Content-Type' => 'text/html; charset=utf-8' }, default_logger)
        res.acceptable_content_type?
      end
    end

    test '#content_type returns Mime::HTML if content type is HTML' do
      res = response('Content-Type' => 'text/html; charset=utf-8')

      assert_equal Mime::HTML, res.content_type
    end

    test '#content_type returns Mime::JSON if content type is JSON' do
      res = response('Content-Type' => 'application/json; charset=utf-8')

      assert_equal Mime::JSON, res.content_type
    end

    private

      def response(headers, logger = nil)
        Response.new([], 200, headers, logger)
      end

      def default_logger
        WebConsole.logger
      end

      def assert_output_to_stderr
        output = capture(:stderr) { yield }
        assert_not output.blank?
      end

      def assert_not_output_to_stderr
        output = capture(:stderr) { yield }
        assert output.blank?
      end
  end
end
