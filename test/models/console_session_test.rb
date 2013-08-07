require 'test_helper'

module WebConsole
  class ConsoleSessionTest < ActionView::TestCase
    include ActiveModel::Lint::Tests

    setup do
      reset_persistent_storage!
      @model1 = @model = new_valid_model
      @model2 = new_valid_model
    end

    test 'consequential ids on creation' do
      assert_equal 1, @model1.id
      assert_equal 2, @model2.id
    end

    test 'populates output on save' do
      model = new_model
      assert_nil model.output
      model.save(input: 'puts "foo"')
      assert_match %r{foo}, model.output
    end

    test 'populates prompt on save' do
      assert_not_nil @model.prompt
    end

    test 'preserved models can be found' do
      id = @model.tap(&:save).id
      assert_equal @model, ConsoleSession.find(id)
    end

    test 'trying to find a model fails if no longer in storage' do
      assert_raises(ConsoleSession::NotFound) { ConsoleSession.find(0) }
    end

    test 'find coerces ids' do
      id = @model.tap(&:save).id
      assert_equal @model, ConsoleSession.find("#{id}")
    end

    test 'not found exceptions are json serializable' do
      exception = assert_raises(ConsoleSession::NotFound) do
        ConsoleSession.find(0)
      end
      assert_equal '{"error":"Session unavailable"}', exception.to_json
    end

    test 'persisted models knows that they are in memory' do
      refute @model.persisted?
      @model.save
      assert @model.persisted?
    end

    test 'persisted models knows about their keys' do
      assert_nil @model.to_key
      @model.save
      assert_equal [1], @model.to_key
    end

    test 'supports json serialization' do
      rails3 = Rails::VERSION::MAJOR == 3

      with_dummy_adapter do
        model = new_model
        expected_nil_json = "{\"id\":3,\"input\":null,\"output\":null,\"prompt\":\"#{rails3 ? ">>" : "\\u003E\\u003E"} \"}"
        assert_equal expected_nil_json, model.to_json

        model.save(input: 'puts "foo"')
        expected_json = "{\"id\":3,\"input\":\"puts \\\"foo\\\"\",\"output\":\"foo\\n=#{rails3 ? ">" : "\\u003E"} nil\\n\",\"prompt\":\"#{rails3 ? ">>" : "\\u003E\\u003E"} \"}"
        assert_equal expected_json, model.to_json
      end
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

      def new_valid_model(attributes = {})
        attributes.merge!(input: 'puts "foo"') unless attributes[:input].present?
        new_model(attributes)
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
