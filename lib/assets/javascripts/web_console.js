//= require term

;(function(BaseTerminal) {

  // Expose the main WebConsole namespace.
  var WebConsole = this.WebConsole = {};

  // Follow term.js example and expose inherits and EventEmitter.
  var inherits = WebConsole.inherits = BaseTerminal.inherits;
  var EventEmitter = WebConsole.EventEmitter = BaseTerminal.EventEmitter;

  var Terminal = WebConsole.Terminal = function(options) {
    if (typeof options === 'number') {
      return BaseTerminal.apply(this, arguments);
    }

    BaseTerminal.call(this, options || (options = {}));

    this.open();

    if (!(options.rows || options.cols) || !options.geometry) {
      this.fitScreen();
    }
  };

  // Make WebConsole.Terminal inherit from BaseTerminal (term.js).
  inherits(Terminal, BaseTerminal);

  Terminal.prototype.fitScreen = function() {
    var width  = Math.floor(this.element.clientWidth / this.cols);
    var height = Math.floor(this.element.clientHeight / this.rows);

    var rows = Math.floor(window.innerHeight / height);
    var cols = Math.floor(this.parent.clientWidth / width);

    this.resize(cols, rows);

    return [cols, rows];
  };

}).call(this, Terminal);
