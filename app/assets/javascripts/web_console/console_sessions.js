//= require web-console

var AJAXTransport = (function(WebConsole) {

  var inherits = WebConsole.inherits;
  var EventEmitter = WebConsole.EventEmitter;

  var FORM_MIME_TYPE = 'application/x-www-form-urlencoded; charset=utf-8';

  var AJAXTransport = function(options) {
    EventEmitter.call(this);
    options || (options = {});

    this.url = (typeof options.url === 'string') ? {
      input: options.url,
      pendingOutput: options.url,
      configuration: options.url
    } : options.url;

    this.pendingInput  = '';

    this.initializeEventHandlers();
  };

  inherits(AJAXTransport, EventEmitter);

  // Initializes the default event handlers.
  AJAXTransport.prototype.initializeEventHandlers = function() {
    this.on('input', this.sendInput);
    this.on('configuration', this.sendConfiguration);
    this.once('initialization', function(cols, rows) {
      this.emit('configuration', cols, rows);
      this.pollForPendingOutput();
    });
  };

  // Shorthand for creating XHR requests.
  AJAXTransport.prototype.createRequest = function(method, url, options) {
    options || (options = {});

    var request = new XMLHttpRequest;
    request.open(method, url);

    if (typeof options.form === 'object') {
      var content = [], form = options.form;

      for (var key in form) {
        var value = form[key];
        content.push(encodeURIComponent(key) + '=' + encodeURIComponent(value));
      }

      request.setRequestHeader('Content-Type', FORM_MIME_TYPE);
      request.data = content.join('&');
    }

    return request;
  };

  AJAXTransport.prototype.pollForPendingOutput = function() {
    var request = this.createRequest('GET', this.url.pendingOutput);

    var self = this;
    request.onreadystatechange = function() {
      if (request.readyState === XMLHttpRequest.DONE) {
        if (request.status === 200) {
          self.emit('pendingOutput', request.responseText);
          self.pollForPendingOutput();
        } else {
          self.emit('disconnect', request);
        }
      }
    };

    request.send(null);
  };

  // Send the input to the server.
  //
  // Each key press is encoded to an intermediate format, before it is sent to
  // the server.
  //
  // WebConsole#keysPressed is an alias for WebConsole#sendInput.
  AJAXTransport.prototype.sendInput = function(input) {
    input || (input = '');

    if (this.disconnected) return;
    if (this.sendingInput) return this.pendingInput += input;

    // Indicate that we are starting to send input.
    this.sendingInput = true;

    var request = this.createRequest('PUT', this.url.input, {
      form: { input: this.pendingInput + input }
    });

    // Clear the pending input.
    this.pendingInput = '';

    var self = this;
    request.onreadystatechange = function() {
      if (request.readyState === XMLHttpRequest.DONE) {
        self.sendingInput = false;
        if (self.pendingInput) self.sendInput();
      }
    };

    request.send(request.data);
  };

  // Send the terminal configuration to the server.
  //
  // Right now by configuration, we understand the terminal widht and terminal
  // height.
  //
  // WebConsole#resized is an alias for WebConsole#sendconfiguration.
  AJAXTransport.prototype.sendConfiguration = function(cols, rows) {
    if (this.disconnected) return;

    var request = this.createRequest('PUT', this.url.configuration, {
      form: { width: cols, height: rows }
    });

    // Just send the configuration and don't care about any output.
    request.send(request.data);
  };

  return AJAXTransport;

}).call(this, WebConsole);

window.addEventListener('load', function() {
  var geometry = calculateFitScreenGeometry();
  config.terminal.cols = geometry[0];
  config.terminal.rows = geometry[1];

  var terminal = window.terminal = new WebConsole.Terminal(config.terminal);

  terminal.on('data', function(data) {
    transport.emit('input', data);
  });

  var transport = new AJAXTransport(config.transport);

  transport.on('pendingOutput', function(response) {
    var json = JSON.parse(response);
    if (json.output) terminal.write(json.output);
  });

  transport.on('disconnect', function() {
    terminal.destroy();
  });

  transport.emit('initialization', terminal.cols, terminal.rows);

  // Utilities
  // ---------

  function calculateFitScreenGeometry() {
    // Currently, resizing term.js is broken. E.g. opening vi causes it to go
    // back to 80x24 and fail with off-by-one error. Other stuff, like chip8
    // are rendered incorrectly and so on.
    //
    // To work around it, create a temporary terminal, just so we can get the
    // best dimensions for the screen.
    var temporary = new WebConsole.Terminal;
    try {
      return temporary.fitScreen();
    } finally {
      temporary.destroy();
    }
  }
});
