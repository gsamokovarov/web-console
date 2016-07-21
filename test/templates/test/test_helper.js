(function() {
  'use strict';

  function FakeKeyEvent(key) {
    this.keyCode = key;
    this.preventDefault = function() {};
    this.stopPropagation = function() {};
  }

  var TestHelper = {
    triggerEvent: function(el, eventName) {
      var event = document.createEvent("MouseEvents");
      event.initEvent(eventName, true, true); // type, bubbles, cancelable
      el.dispatchEvent(event);
    },
    keyDown: function(keyCode) {
      return new FakeKeyEvent(keyCode);
    }
  };

  window.TestHelper = TestHelper;
  window.assert = chai.assert;
})();
