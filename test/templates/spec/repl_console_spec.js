describe("REPLConsole", function() {
  SpecHelper.prepareStageElement();

  describe("#swapWord", function() {
    beforeEach(function() {
      var elm = document.createElement('div');
      elm.innerHTML = '<div id="console"></div>';
      this.stageElement.appendChild(elm);
      var consoleOptions = { mountPoint: '/mock', sessionId: 'result' };
      this.console = REPLConsole.installInto('console', consoleOptions);
    });
    context("caret points to last item", function() {
      beforeEach(function() {
        this.console.setInput('hello world');
        this.console.swapCurrentWord('swapped');
      });
      it('should be last word', function() { assert.equal(this.console._input, 'hello swapped'); });
    });
    context("points to first item", function() {
      beforeEach(function() {
        this.console.setInput('hello world', 3);
        this.console.swapCurrentWord('swapped');
      });
      it('should be first word', function() { assert.equal(this.console._input, 'swapped world'); });
    });
  });

  describe("#getCurrentWord", function() {
    beforeEach(function() {
      var elm = document.createElement('div');
      elm.innerHTML = '<div id="console"></div>';
      this.stageElement.appendChild(elm);
      var consoleOptions = { mountPoint: '/mock', sessionId: 'result' };
      this.console = REPLConsole.installInto('console', consoleOptions);
    });
    context("caret points to last item", function() {
      beforeEach(function() { this.console.setInput('hello world'); });
      it('should be last word', function() { assert.equal(this.console.getCurrentWord(), 'world'); });
    });
    context("points to first item", function() {
      beforeEach(function() { this.console.setInput('hello world', 0); });
      it('should be first word', function() { assert.equal(this.console.getCurrentWord(), 'hello'); });
    });
  });

  describe("#commandHandle", function() {
    function runCommandHandle(self, consoleOptions, callback) {
      self.console = REPLConsole.installInto('console', consoleOptions);
      self.console.commandHandle('fake-input', function(result, response) {
        self.result   = result;
        self.response = response;
        self.message  = self.elm.getElementsByClassName('console-message')[0];
        callback();
      });
    }

    beforeEach(function() {
      this.elm = document.createElement('div');
      this.elm.innerHTML = '<div id="console"></div>';
      this.stageElement.appendChild(this.elm);
    });

    context("sessionId=result", function() {
      beforeEach(function(done) {
        runCommandHandle(this, { mountPoint: '/mock', sessionId: 'result' }, done);
      });
      it("should be a successful request", function() {
        assert.ok(this.result);
      })
      it("should have fake-result in output", function() {
        assert.match(this.response.output, /"fake-result"/);
      });
      it("should not have .error-message", function() {
        assert.notOk(hasClass(this.message, 'error-message'));
      });
    });

    context("sessionId=error", function() {
      beforeEach(function(done) {
        runCommandHandle(this, { mountPoint: '/mock', sessionId: 'error' }, done);
      });
      it("should not be a successful request", function() {
        assert.notOk(this.result);
      });
      it("should have fake-error-message in output", function() {
        assert.match(this.response.output, /fake-error-message/);
      });
      it("should have .error-message", function() {
        assert.ok(hasClass(this.message, 'error-message'));
      });
    });

    context("sessionId=error.txt", function() {
      beforeEach(function(done) {
        runCommandHandle(this, { mountPoint: '/mock', sessionId: 'error.txt' }, done);
      });
      it("should output HTTP status code", function() {
        assert.match(this.message.innerHTML, /400 Bad Request/);
      });
    });
  });

  describe(".installInto", function() {
    beforeEach(function() {
      this.elm = document.createElement('div');
      this.elm.innerHTML = '<div id="console" data-mount-point="attr-mount-point" ' +
        'data-session-id="attr-session-id" ' +
        'data-prompt-label="attr-prompt-label"></div>';
      this.stageElement.appendChild(this.elm);
    });

    context("install console without options", function() {
      beforeEach(function() {
        this.console = REPLConsole.installInto('console');
      });
      it("should have attr-prompt-label", function() {
        assert.equal(this.console.prompt, 'attr-prompt-label');
      });
      it("should have attr-mount-point", function() {
        assert.equal(this.console.mountPoint, 'attr-mount-point');
      });
      it("should have attr-session-id", function() {
        assert.equal(this.console.sessionId, 'attr-session-id');
      });
    });

    context("install console with options", function() {
      beforeEach(function() {
        var options = { mountPoint: 'opt-mount-point', sessionId: 'opt-session-id' };
        this.console = REPLConsole.installInto('console', options);
      });
      it("should have opt-mount-point", function() {
        assert.equal(this.console.mountPoint, 'opt-mount-point');
      });
      it("should have opt-session-id", function() {
        assert.equal(this.console.sessionId, 'opt-session-id');
      });
    });
  });

  describe("#install", function() {
    beforeEach(function() {
      this.elm = document.createElement("div");
      this.stageElement.appendChild(this.elm);
    });

    context("install console", function() {
      beforeEach(function() {
        var replConsole = new REPLConsole;
        replConsole.install(this.elm);
      });
      it("should have .console", function() {
        assert.ok(hasClass(this.elm, "console"));
      });
      it("should have a inner", function() {
        assert.equal(this.elm.getElementsByClassName("console-inner").length, 1);
      });
      it("should have a resizer", function() {
        assert.equal(this.elm.getElementsByClassName("resizer").length, 1);
      });
      it("should have a close button", function() {
        assert.equal(this.elm.getElementsByClassName("close-button").length, 1);
      });
    });
  });

  describe("console actions", function() {
    describe("close action", function() {
      beforeEach(function() {
        this.elm = document.createElement("div");
        this.elmId = this.elm.id = SpecHelper.randomString();
        this.stageElement.appendChild(this.elm);
        var replConsole = new REPLConsole;
        replConsole.install(this.elm);
      });

      context("click close button", function() {
        beforeEach(function() {
          var closeButton = this.elm.getElementsByClassName("close-button")[0];
          SpecHelper.triggerEvent(closeButton, "click");
        });
        it("should be removed from the parent node", function() {
          assert.isNull(document.getElementById(this.elmId));
        });
      });
    });
  });
});
