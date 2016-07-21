(function() {
  'use strict';

  var TestHelper = {
    KEY_TAB: 9,
    KEY_ENTER: 13,
    triggerEvent: function(el, eventName) {
      var event = document.createEvent("MouseEvents");
      event.initEvent(eventName, true, true); // type, bubbles, cancelable
      el.dispatchEvent(event);
    },
    keyDown: function(keyCode) {
      return {
        keyCode: keyCode,
        preventDefault: function() {},
        stopPropagation: function() {}
      };
    }
  };

  window.TestHelper = TestHelper;
  window.assert = chai.assert;
})();
