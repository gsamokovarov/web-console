require 'test_helper'

module WebConsole
  class ConsoleSessionTest < ActionView::TestCase
    include ActiveModel::Lint::Tests

    setup do
      @model = new_model
    end

    test 'creation with consequential ids' do
      assert_equal 1, @model.id
      assert_equal 2, new_model.id
    end

    private
      def new_model(attributes = {})
        ConsoleSession.new(attributes)
      end
  end
end
