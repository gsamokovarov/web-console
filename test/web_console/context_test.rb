require 'test_helper'

module WebConsole
  class ContextTest < ActiveSupport::TestCase
    test '#extract(empty) includes local variables' do
      local_var = 'local'
      assert Context.new(binding).extract('').include?(:local_var)
    end

    test '#extract(empty) includes instance variables' do
      @instance_var = 'instance'
      assert Context.new(binding).extract('').include?(:@instance_var)
    end

    test '#extract(empty) includes global variables' do
      $global_var = 'global'
      assert Context.new(binding).extract('').include?(:$global_var)
    end

    test '#extract(obj) returns methods' do
      assert Context.new(binding).extract('Rails').include?('Rails.root')
    end

    test '#extract(obj) returns constants' do
      assert Context.new(binding).extract('WebConsole').include?('WebConsole::Middleware')
    end
  end
end
