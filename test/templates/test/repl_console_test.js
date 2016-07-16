suite('REPLCosnole', function() {
  suiteSetup(function() {
    this.stage = document.createElement('div');
    document.body.appendChild(this.stage);
  });

  setup(function() {
    var elm = document.createElement('div');
    elm.innerHTML = '<div id="console"></div>';
    this.stage.appendChild(elm);
    var consoleOptions = { mountPoint: '/mock', sessionId: 'result' };
    this.console = REPLConsole.installInto('console', consoleOptions);
  });

  teardown(function() { removeAllChildren(this.stage); });

  test('swap last word', function() {
    this.console.setInput('hello world');
    this.console.swapCurrentWord('word');

    assert.equal(this.console._input, 'hello word');
  });

  test('swap first word', function() {
    this.console.setInput('hello world');
    this.console._caretPos = 0;
    this.console.swapCurrentWord('my');

    assert.equal(this.console._input, 'my world');
  });

  test('current word', function() {
    this.console.setInput('hello world');
    assert.equal(this.console.getCurrentWord(), 'world');
    this.console._caretPos = 0;
    assert.equal(this.console.getCurrentWord(), 'hello');
    this.console._caretPos = 5;
    assert.equal(this.console.getCurrentWord(), '');
    this.console._caretPos = 6;
    assert.equal(this.console.getCurrentWord(), 'world');
  });
});
