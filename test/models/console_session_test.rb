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

    test 'consequential ids in storage' do
      assert @model1.save
      assert @model2.save
      assert_equal 1, @model1.id
      assert_equal 2, @model2.id
    end

    test 'invalid without input' do
      assert_not new_model.valid?
    end

    test 'valid with input' do
      assert new_valid_model.valid?
    end

    test 'populates output on save' do
      assert_nil @model.output
      @model.save
      assert_match %r{foo}, @model.output
    end

    test 'populates prompt on save' do
      assert_nil @model.prompt
      @model.save
      assert_not_nil @model.prompt
    end

    private
      def new_model(attributes = {})
        ConsoleSession.new(attributes)
      end

      def new_valid_model(attributes = {})
        attributes.merge!(input: 'puts "foo"') unless attributes[:input].present?
        new_model(attributes)
      end

      def clear_inmemory_storage!
        ConsoleSession::INMEMORY_STORAGE.clear
      end
  end
end
