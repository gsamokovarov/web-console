require 'test_helper'

class REPLTest < ActiveSupport::TestCase
  setup    { @repl = WebConsole::REPL.new }
  teardown { @repl.dispose.try(:join) }
end
