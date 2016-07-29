suite('Autocomplete', function() {
  suite('Trimming', function() {
    test('prefix and suffix stands for that the list includes trimmed elements', function() {
      var ac = new Autocomplete(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']);
      assert.equal(ac.prefix, ac.view.children[0]);
      assert.equal(ac.prefix.innerText, ac.view.children[0].innerText);
      assert.equal(ac.suffix, ac.view.children[ac.words.length + 1]);
      assert.equal(ac.suffix.innerText, ac.view.children[ac.words.length + 1].innerText);
      assertTrimmed(ac.prefix);
      assertNotTrimmed(ac.suffix);

      // A B C D E ...
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertTrimmed(ac.prefix);
      assertNotTrimmed(ac.suffix);

      // ... B C D E F ...
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertNotTrimmed(ac.prefix);
      assertNotTrimmed(ac.suffix);

      // A: A B C D E ... (shift)
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB, { shiftKey: true }));
      assertTrimmed(ac.prefix);
      assertNotTrimmed(ac.suffix);

      // ... D E F G H
      for (var i = 0; i <= ac.words.indexOf('D'); ++i) ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertNotTrimmed(ac.prefix);
      assertTrimmed(ac.suffix);
    });

    test('prefix and suffix are always trimmed if the list has few items', function() {
      var ac = new Autocomplete(['A', 'B', 'C']);
      assertTrimmed(ac.prefix);
      assertTrimmed(ac.suffix);

      // A
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertTrimmed(ac.prefix);
      assertTrimmed(ac.suffix);

      // B
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertTrimmed(ac.prefix);
      assertTrimmed(ac.suffix);

      // C
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertTrimmed(ac.prefix);
      assertTrimmed(ac.suffix);
    });

    test('shows only five elements after the current element', function() {
      var ac = new Autocomplete(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']);

      // A B C D E ...
      assert.equal(-1, ac.current);
      assertNotClass(ac, 0, 5, 'trimmed');
      assertClass(ac, 5, ac.words.length, 'trimmed');

      // A: A B C D E ...
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertNotClass(ac, 0, 5, 'trimmed');
      assertClass(ac, 5, ac.words.length, 'trimmed');

      // B: B C D E F ...
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertClass(ac, 0, 1, 'trimmed');
      assertNotClass(ac, 1, 6, 'trimmed');
      assertClass(ac, 6, ac.words.length, 'trimmed');

      // A: A B C D E ... (shift)
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB, { shiftKey: true }));
      assert.equal(0, ac.current);
      assertNotClass(ac, 0, 5, 'trimmed');
      assertClass(ac, 5, ac.words.length, 'trimmed');
    });

    test('keeps to show the last five elements', function() {
      var ac = new Autocomplete(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']);

      // G: D E F G H
      for (var i = 0; i <= ac.words.indexOf('G'); ++i) ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assert.equal(6, ac.current);
      assertClass(ac, 0, 3, 'trimmed');
      assertNotClass(ac, 3, ac.words.length, 'trimmed');

      // H: D E F G H (keep last five elements)
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assert.equal(7, ac.current);
      assertClass(ac, 0, 3, 'trimmed');
      assertNotClass(ac, 3, ac.words.length, 'trimmed');

      // A: A B C D E ...
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assertNotClass(ac, 0, 5, 'trimmed');
      assertClass(ac, 5, ac.words.length, 'trimmed');

      // H: D E F G H (shift)
      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB, { shiftKey: true }));
      assert.equal(7, ac.current);
      assertClass(ac, 0, 3, 'trimmed');
      assertNotClass(ac, 3, ac.words.length, 'trimmed');
    });

    test('shows five elements if prefix is passed', function() {
      var ac = new Autocomplete(['A', 'B1', 'B2', 'B3', 'C'], 'B');
      assert.equal(0, ac.current);
      assertClass(ac, 0, 1, 'trimmed');
      assertNotClass(ac, 1, 4, 'trimmed');
      assertClass(ac, 4, ac.words.length, 'trimmed');

      ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
      assert.equal(1, ac.current);
      assertClass(ac, 0, 1, 'trimmed');
      assertNotClass(ac, 1, 4, 'trimmed');
      assertClass(ac, 4, ac.words.length, 'trimmed');
    });
  });

  suite('Refinements', function() {
    setup(function() {
      this.ac = new Autocomplete(['other', 'other2', 'something', 'somewhat', 'somewhere', 'test']);
      this.refine = function(prefix) { this.ac.refine(prefix); };
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
  });

  suite('Edge Cases', function() {
    test('does nothing if the word list is empty', function() {
      var ac = new Autocomplete([]);
      assert.doesNotThrow(function() {
        ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_TAB));
        ac.onKeyDown(TestHelper.keyDown(TestHelper.KEY_ENTER));
      });
    });
  });

  function assertClass(ac, left, right, className) {
    for (var i = left; i < right; ++i) {
      assert.ok(hasClass(ac.item(i), className), i + '-th element shuold have ' + className);
    }
  }

  function assertNotClass(ac, left, right, className) {
    for (var i = left; i < right; ++i) {
      assert.notOk(hasClass(ac.item(i), className), i + '-th element should not have ' + className);
    }
  }

  function assertRange(self, left, right, hiddenCnt) {
    assert.equal(left, self.ac.left, 'left');
    assert.equal(right, self.ac.right, 'right');
    if (hiddenCnt) assert.equal(hiddenCnt, self.ac.view.getElementsByClassName('hidden').length, 'hiddenCnt');
  }

  function assertTrimmed(el) {
    assert.ok(hasClass(el, 'trimmed'));
  }

  function assertNotTrimmed(el) {
    assert.notOk(hasClass(el, 'trimmed'));
  }
});
