suite('DOM Helpers', function() {
  test('hasClass() checks if an element contains a class name', function() {
    var div = document.createElement('div');
    assert.notOk(hasClass(div, 'hello'));
    div.className = 'hello';
    assert.ok(hasClass(div, 'hello'));
    div.className = 'hello world';
    assert.ok(hasClass(div, 'hello'));
  });

  test('addClass() adds a class name to an element', function() {
    var div = document.createElement('div');
    assert.notOk(hasClass(div, 'hello'));
    addClass(div, 'hello');
    assert.ok(hasClass(div, 'hello'));
  });

  test('removeClass() removes a class name from an element', function() {
    var div = document.createElement('div');
    div.className = 'hello world';
    removeClass(div, 'hello');
    assert.notOk(hasClass(div, 'hello'));
  });
});
