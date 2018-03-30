# frozen_string_literal: true

require "test_helper"

module WebConsole
  class ContextTest < ActiveSupport::TestCase
    test "#extract(empty) includes local variables" do
      local_var = local_var = "local"
      assert context(binding).include?(:local_var)
    end

    test "#extract(empty) includes instance variables" do
      @instance_var = "instance"
      assert context(binding).include?(:@instance_var)
    end

    test "#extract(empty) includes global variables" do
      $global_var = "global"
      assert context(binding).include?(:$global_var)
    end

    test "#extract(obj) returns methods" do
      assert context(binding, "Rails").include?("Rails.root")
    end

    test "#extract(obj) returns constants" do
      assert context(binding, "WebConsole").include?("WebConsole::Middleware")
    end

    private
      def context(b, o = "")
        Context.new(b).extract(o).flatten
      end
  end
end
