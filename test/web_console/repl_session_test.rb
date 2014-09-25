require 'test_helper'

module WebConsole
  class REPLSessionTest < ActionView::TestCase
    setup do
      WebConsole::REPLSession::INMEMORY_STORAGE.clear
      @model1 = @model = WebConsole::REPLSession.new binding: TOPLEVEL_BINDING
      @model2 = WebConsole::REPLSession.new binding: TOPLEVEL_BINDING
    end

    test 'raises WebConsole::REPLSession::NotFound on not found sessions' do
      assert_raises(WebConsole::REPLSession::NotFound) { WebConsole::REPLSession.find("nonexistent session") }
    end

    test 'find returns a persisted object' do
      assert_equal @model.save, WebConsole::REPLSession.find(@model.id)
    end

    test 'not found exceptions are JSON serializable' do
      exception = assert_raises(WebConsole::REPLSession::NotFound) { WebConsole::REPLSession.find("nonexistent session") }
      assert_equal '{"error":"Session unavailable"}', exception.to_json
    end

    test 'create gives already persisted models' do
      assert WebConsole::REPLSession.create(binding: TOPLEVEL_BINDING).persisted?
    end

    test 'no gives not persisted models' do
      assert_not WebConsole::REPLSession.new(binding: TOPLEVEL_BINDING).persisted?
    end
  end
end
