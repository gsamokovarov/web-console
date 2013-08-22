require 'test_helper'

module WebConsole
  class ConsoleSessionTest < ActionView::TestCase
    include ActiveModel::Lint::Tests

    setup do
      PTY.stubs(:spawn).returns([String.new, String.new, Random.rand(20000)])
      reset_persistent_storage!
      @model1 = @model = new_model
      @model2 = new_model
    end

    test 'trying to find a model fails if no longer in storage' do
      assert_raises(ConsoleSession::NotFound) { ConsoleSession.find(0) }
    end

    test 'find coerces ids' do
      assert_equal @model.persist, ConsoleSession.find("#{@model.pid}")
    end

    test 'not found exceptions are json serializable' do
      exception = assert_raises(ConsoleSession::NotFound) do
        ConsoleSession.find(0)
      end
      assert_equal '{"error":"Session unavailable"}', exception.to_json
    end

    test 'persisted models knows that they are in memory' do
      refute @model.persisted?
      @model.persist
      assert @model.persisted?
    end

    test 'persisted models knows about their keys' do
      assert_nil @model.to_key
      @model.persist
      assert_not_nil @model.to_key
    end

    test 'create gives already persisted models' do
      assert ConsoleSession.create.persisted?
    end

    test 'no gives not persisted models' do
      refute ConsoleSession.new.persisted?
    end

    private

      def new_model(attributes = {})
        ConsoleSession.new(attributes)
      end

      def reset_persistent_storage!
        ConsoleSession::INMEMORY_STORAGE.clear
        ConsoleSession.class_variable_set(:@@counter, 0)
      end

      def with_dummy_adapter
        previous_method = WebConsole::REPL.method(:default)
        WebConsole::REPL.module_eval do
          define_singleton_method(:default) { WebConsole::REPL::Dummy }
        end
        yield
      ensure
        WebConsole::REPL.module_eval do
          define_singleton_method(:default, &previous_method)
        end
      end
  end
end
