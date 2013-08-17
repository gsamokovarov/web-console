//= require vt100

(function() {

  // Store utilities in an underscore-like object.
  var _ = {
    // Simple prototypical inheritence helper.
    //
    // Forces `cls` to inherit from `base` prototype.
    inherits: function(cls, base) {
      var constructor = _.noop();
      constructor.prototype = base.prototype;
      cls.prototype = new constructor();
      cls.prototype.constructor = cls;
    },

    // Factory for empty functions.
    noop: function() {
      return function() {};
    },

    // Binds a function to an explicit context.
    bind: Function.prototype.bind ? function(func, context) {
      return func.bind(context);
    } : function(func, context) {
      return function() {
        return func.apply(context, arguments);
      };
    }
  };

  // Expose the main WebConsole namespace.
  var WebConsole = this.WebConsole = {};

  // Use an IE friendly implementation of XMLHttpRequest.
  WebConsole.XHR = (function() {
    try {
      return XMLHttpRequest;
    } catch (e) {
      var constructor = function() {
        return new ActiveXObject('Microsoft.XMLHTTP');
      };
      // Attach the XHR ready states as constants.
      constructor.UNSET            = 0;
      constructor.OPENED           = 1;
      constructor.HEADERS_RECEIVED = 2;
      constructor.LOADING          = 3;
      constructor.DONE             = 3;
      return constructor;
    }
  }).call(this);

  WebConsole.Terminal = function(options) {
    options || (options = {});

    if (typeof options.url === 'string') {
      this.url = {
        input: options.url,
        pendingOutput: options.url
      }
    } else {
      this.url = options.url;
    }

    VT100.call(this);
    this.requestPendingOutput();
  };

  // Inherit from VT100.
  _.inherits(WebConsole.Terminal, VT100);

  // Shorthand for creating XHR requests.
  WebConsole.Terminal.prototype.createRequest = function(method, url, options) {
    options || (options = {});

    var request = new WebConsole.XHR();
    request.open(method, url);

    if (typeof options.form === 'object') {
      var content = [], form = options.form;

      for (var key in form) {
        var value = form[key];
        content.push(encodeURIComponent(key) + '=' + encodeURIComponent(value));
      }

      var formMimeType = 'application/x-www-form-urlencoded; charset=utf-8';
      request.setRequestHeader('Content-Type', formMimeType);
      request.data = content.join('&');
    }

    return request;
  };

  WebConsole.Terminal.prototype.clearPendingInput = function() {
    this.pendingInput = '';
  };

  WebConsole.Terminal.prototype.feedPendingInput = function(input) {
    (this.pendingInput === void 0) && (this.pendingInput = '');
    this.pendingInput += input;
  };

  WebConsole.Terminal.prototype.requestPendingOutput = function() {
    var request = this.createRequest('GET', this.url.pendingOutput);

    request.onreadystatechange = _.bind(function() {
      var response;

      if (request.readyState === WebConsole.XHR.DONE) {
        if (request.status === 200) {
          this.connected = true;

          response = JSON.parse(request.responseText);
          if (response.output) this.vt100(response.output);

          this.requestPendingOutput();
        } else {
          try {
            // Try to parse the error if it is a JSON.
            response = JSON.parse(request.responseText);
          } catch(e) {
            // No luck with that, but it's not a big deal.
          }
          this.disconnect(response && response.error);
        }
      }
    }, this);

    request.send(null);
  };

  WebConsole.Terminal.prototype.sendInput = function(input) {
    input || (input = '');

    if (!this.connected) return;
    if (this.sendingInput) return this.feedPendingInput(input);

    // Indicate that we are starting to send input.
    this.sendingInput = true;

    var request = this.createRequest('PUT', this.url.input, {
      form: { input: this.pendingInput + input }
    });

    // Clear the pending input.
    this.clearPendingInput();

    request.onreadystatechange = _.bind(function() {
      if (request.readyState === WebConsole.XHR.DONE) {
        this.sendingInput = false;
        if (this.pendingInput) this.sendInput();
      }
    }, this);

    request.send(request.data);
  };

  WebConsole.Terminal.prototype.disconnect = function(message) {
    this.connected = false;
    if (this.cursorX > 0) this.vt100('\n');
    this.vt100(message || 'Session closed');
  };

  (function() {
    var hex = function(pos) {
      return hex.characters.charAt(pos);
    };

    hex.characters = '0123456789ABCDEF';

    // Encodes the pressed keys to an intermediate format that can be decoded
    // to text with proper escapate sequences.
    //
    // This is an override for VT100#keysPressed.
    //
    // Algorhithm by Markus Gutschke from http://shellinabox.com.
    WebConsole.Terminal.prototype.keysPressed = function(input) {
      var encoded = '';

      for (var i = 0, c = input.charCodeAt(i); i < input.length; i++) {
        if (c < 128) {
          encoded += hex(c >> 4) + hex(c & 0xF);
        } else if (c < 0x800) {
          encoded +=
            hex(0xC + (c >> 10))         +
            hex((c >> 6) & 0xF)          +
            hex(0x8 + ((c >> 4) & 0x3))  +
            hex(c & 0xF);
        } else if (c < 0x10000) {
          encoded += 'E'                 +
            hex(c >> 12)                 +
            hex(0x8 + ((c >> 10) & 0x3)) +
            hex((c >> 6) & 0xF)          +
            hex(0x8 + ((c >> 4) & 0x3))  +
            hex(c & 0xF);
        } else if (c < 0x110000) {
          encoded += 'F'                 +
            hex(c >> 18)                 +
            hex(0x8 + ((c >> 16) & 0x3)) +
            hex((c >> 12) & 0xF)         +
            hex(0x8 + ((c >> 10) & 0x3)) +
            hex((c >> 6) & 0xF)          +
            hex(0x8 + ((c >> 4) & 0x3))  +
            hex(c & 0xF);
        }
      }

      this.sendInput(encoded);
    };
  }).call(this);

}).call(this);
