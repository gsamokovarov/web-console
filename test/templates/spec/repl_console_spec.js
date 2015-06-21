describe("REPLConsole", function() {
  SpecHelper.prepareStageElement();

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
