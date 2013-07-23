require 'test_helper'

module WebConsole
  class ConsoleSessionTest < ActionView::TestCase
    include ActiveModel::Lint::Tests

    setup do
      @model1 = @model = new_valid_model
      @model2 = new_valid_model
    end

    teardown do
      clear_inmemory_storage!
    end

    test 'storing with consequential ids' do
      assert @model1.save
      assert @model2.save
      assert_equal 1, @model1.id
      assert_equal 2, @model2.id
    end

    private
      def new_model(attributes = {})
        ConsoleSession.new(attributes)
      end

      def new_valid_model(attributes = {})
        attributes.merge!(input: 'foo') unless attributes[:input].present?
        new_model(attributes)
      end

      def clear_inmemory_storage!
        ConsoleSession::INMEMORY_STORAGE.clear
      end
  end
end
