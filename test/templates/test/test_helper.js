(function() {
  'use strict';

  var TestHelper = {
    KEY_TAB: 9,
    KEY_ENTER: 13,
    KEY_E: 69,
    triggerEvent: function(el, eventName) {
      var event = document.createEvent("MouseEvents");
      event.initEvent(eventName, true, true); // type, bubbles, cancelable
      el.dispatchEvent(event);
    },
    keyDown: function(keyCode, options) {
      options = options || {};
      return {
        keyCode: keyCode,
        ctrlKey: options.ctrlKey,
        shiftKey: options.shiftKey,
        preventDefault: function() {},
        stopPropagation: function() {}
      };
    }
  };

  window.TestHelper = TestHelper;
  window.assert = chai.assert;
})();
