suite('Autocomplete', function() {
  setup(function() {
    this.ac = new Autocomplete(['other', 'other2', 'something', 'somewhat', 'somewhere', 'test']);
    this.refine = function(prefix) { this.ac.refine(prefix); };
  });

  test('does nothing if the word list is empty', function() {
    var ac = new Autocomplete([]);
    assert.doesNotThrow(function() {
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_ENTER));
    });
  });

  test('empty string', function() {
    this.refine('');

    assert(!this.ac.confirmed);
    assertRange(this, 0, this.ac.words.length, 0);
  });

  test('some', function() {
    this.refine('some');

    assert(!this.ac.confirmed);
    assertRange(this, 2, this.ac.words.length - 1, 3);
  });

  test('confirmable', function() {
    this.refine('somet');

    assert.equal(this.ac.confirmed, 'something');
    assertRange(this, 2, 3);
  });

  test('decrement', function() {
    this.refine('o');
    this.refine('');

    assertRange(this, 0, this.ac.words.length, 0);
  });

  test('other => empty => some', function() {
    this.refine('other');
    this.refine('');
    this.refine('some');

    assertRange(this, 2, this.ac.words.length - 1, 3);
  });

  test('some => empty', function() {
    this.refine('some');
    this.refine('');

    assertRange(this, 0, this.ac.words.length);
  });

  function assertRange(self, left, right, hiddenCnt) {
    assert.equal(left, self.ac.left, 'left');
    assert.equal(right, self.ac.right, 'right');
    if (hiddenCnt) assert.equal(hiddenCnt, self.ac.view.getElementsByClassName('hidden').length, 'hiddenCnt');
  }
});
