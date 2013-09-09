require 'test_helper'

module WebConsole
  class ConsoleSessionTest < ActionView::TestCase
    include ActiveModel::Lint::Tests

    setup do
      PTY.stubs(:spawn).returns([String.new, String.new, Random.rand(20000)])
      ConsoleSession::INMEMORY_STORAGE.clear
      @model1 = @model = ConsoleSession.new
      @model2 = ConsoleSession.new
    end

    test 'raises ConsoleSession::Unavailable on not found sessions' do
      assert_raises(ConsoleSession::Unavailable) { ConsoleSession.find(-1) }
    end

    test 'find coerces ids' do
      assert_equal @model.persist, ConsoleSession.find("#{@model.pid}")
    end

    test 'not found exceptions are json serializable' do
      exception = assert_raises(ConsoleSession::Unavailable) { ConsoleSession.find(-1) }
      assert_equal '{"error":"Session unavailable"}', exception.to_json
    end

    test 'can be used as slave as the methods are delegated' do
      slave_methods = Slave.instance_methods - @model.methods
      slave_methods.each { |method| assert @model.respond_to?(method) }
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
  end
end
