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
        pendingOutput: options.url,
        configuration: options.url
      };
    } else {
      this.url = options.url;
    }

    VT100.call(this);

    this.requestPendingOutput();
  };

  // Inherit from VT100.
  _.inherits(WebConsole.Terminal, VT100);

  // Try to be minimalistic and disable the context menu.
  WebConsole.Terminal.prototype.showContextMenu = _.noop();

  // Don't show the current size on resize.
  WebConsole.Terminal.prototype.showCurrentSize = _.noop();

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
          response = JSON.parse(request.responseText);
          if (response.output) {
            this.vt100(unescape(encodeURIComponent(response.output)));
          }

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

  // Send the input to the server.
  //
  // Each key press is encoded to an intermediate format, before it is sent to
  // the server.
  //
  // WebConsole#keysPressed is an alias for WebConsole#sendInput.
  WebConsole.Terminal.prototype.sendInput =
  WebConsole.Terminal.prototype.keysPressed = function(input) {
    input || (input = '');

    if (this.disconnected) return;
    if (this.sendingInput) return this.feedPendingInput(input);

    // Indicate that we are starting to send input.
    this.sendingInput = true;

    var request = this.createRequest('PUT', this.url.input, {
      form: { input: (this.pendingInput || '') + input }
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

  // Send the terminal configuration to the server.
  //
  // Right now by configuration, we understand the terminal widht and terminal
  // height.
  //
  // WebConsole#resized is an alias for WebConsole#sendconfiguration.
  WebConsole.Terminal.prototype.sendConfiguration =
  WebConsole.Terminal.prototype.resized = function() {
    if (this.disconnected) return;

    var request = this.createRequest('PUT', this.url.configuration, {
      form: { width: this.terminalWidth, height: this.terminalHeight }
    });

    // Just send the configuration and don't care about any output.
    request.send(request.data);
  };

  // Don't send any more requests to the server.
  WebConsole.Terminal.prototype.disconnect = function(message) {
    this.disconnected = true;
    if (this.cursorX > 0) this.vt100('\r\n');
    this.vt100(message || 'Disconnected');
  };

}).call(this);
