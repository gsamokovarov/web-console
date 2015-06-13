var assert = chai.assert;

describe("DOM helpers", function() {
  describe("hasClass()", function() {
    context("create a <div>", function() {
      beforeEach(function() {
        this.div = document.createElement("div");
      });

      context("class=hello", function() {
        beforeEach(function() {
          this.div.className = "hello";
        });
        it("should have .hello", function() {
          assert.ok(hasClass(this.div, "hello"));
        });
        it("should not have .world", function() {
          assert.notOk(hasClass(this.div, "world"));
        });
      });

      context("class=hello world", function() {
        beforeEach(function() {
          this.div.className = "hello world";
        });
        it("should have .hello", function() {
          assert.ok(hasClass(this.div, "hello"));
        });
        it("should have .world", function() {
          assert.ok(hasClass(this.div, "world"));
        });
        it("should not have .not-world", function() {
          assert.notOk(hasClass(this.div, "not-world"));
        });
      });
    });
  });

  describe("addClass()", function() {
    context("create a <div>", function() {
      beforeEach(function() {
        this.div = document.createElement("div");
      });

      context("addClass(div, hello)", function() {
        beforeEach(function() {
          addClass(this.div, "hello");
        });
        it("should have .hello", function() {
          assert.ok(hasClass(this.div, "hello"));
        });
      });
    });

    context("create a <div class=hello>", function() {
      beforeEach(function() {
        this.div = document.createElement("div");
        this.div.className = "hello";
      });

      context("addClass(div, world)", function() {
        beforeEach(function() {
          addClass(this.div, "world");
        });
        it("should have .hello", function() {
          assert.ok(hasClass(this.div, "hello"));
        });
        it("should also have .world", function() {
          assert.ok(hasClass(this.div, "world"));
        });
      });
    });
  });

  describe("removeClass()", function() {
    context("create a <div class=hello world>", function() {
      beforeEach(function() {
        this.div = document.createElement("div");
        this.div.className = "hello world";
      });

      context("removeClass(hello)", function() {
        beforeEach(function() {
          removeClass(this.div, "hello");
        });
        it("should not have .hello", function() {
          assert.notOk(hasClass(this.div, "hello"));
        });
        it("should have .world", function() {
          assert.ok(hasClass(this.div, "world"));
        });
      });

      context("removeClass(world)", function() {
        beforeEach(function() {
          removeClass(this.div, "world");
        });
        it("should have .hello", function() {
          assert.ok(hasClass(this.div, "hello"));
        });
        it("should not have .world", function() {
          assert.notOk(hasClass(this.div, "world"));
        });
      });
    });
  });
});
