describe("REPLConsole", function() {
  SpecHelper.prepareStageElement();

  describe(".installInto()", function() {
    beforeEach(function() {
      this.elm = document.createElement('div');
      this.elm.innerHTML = '<div id="console" data-remote-path="data-remote-path" ' +
        'data-prompt-label="data-prompt-label"></div>';
      this.stageElement.appendChild(this.elm);
    });

    context("install console without options", function() {
      beforeEach(function() {
        this.console = REPLConsole.installInto('console');
      });
      it("should have data-prompt-label", function() {
        assert.equal(this.console.prompt, 'data-prompt-label');
      });
      it("should have data-remote-path", function() {
        assert.equal(this.console.remotePath, 'data-remote-path');
      });
    });

    context("install console with {remotePath: 'opt-remote-path'}", function() {
      beforeEach(function() {
        this.console = REPLConsole.installInto('console', {remotePath: 'opt-remote-path'});
      });
      it("should have opt-remote-path", function() {
        assert.equal(this.console.remotePath, 'opt-remote-path');
      });
    });
  });

  describe("#install()", function() {
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
