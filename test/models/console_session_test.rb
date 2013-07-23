require 'test_helper'

module WebConsole
  class ConsoleSessionTest < ActionView::TestCase
    include ActiveModel::Lint::Tests

    setup do
      clear_inmemory_storage!
      @model1 = @model = new_valid_model
      @model2 = new_valid_model
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

    test 'save fails on invalid models' do
      assert_equal false, new_model.save
    end

    test 'preserved models can be found' do
      id = @model.tap(&:save).id
      assert_equal @model, ConsoleSession.find(id)
    end

    test 'trying to find a model fails if not found' do
      assert_raises(ConsoleSession::NotFound) { ConsoleSession.find(:invalid) }
    end

    test 'persisted models knows that they are in memory' do
      assert_not @model.persisted?
      @model.save
      assert @model.persisted?
    end

    test 'persisted models knows about their keys' do
      assert_nil @model.to_key
      @model.save
      assert_equal [1], @model.to_key
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
        ConsoleSession.class_variable_set(:@@counter, 0)
      end
  end
end
