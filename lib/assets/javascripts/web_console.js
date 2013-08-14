(function() {

  // Expose the main WebConsole namespace.
  var WebConsole = this.WebConsole = {};

  // Convert an ASCII numeric code to plain string.
  var ascii = WebConsole.ascii = String.fromCharCode;

  // Enumerate the ASCII control characters.
  WebConsole.ASCII = {
    NUL: ascii(0),
    SOH: ascii(1),
    STX: ascii(2),
    ETX: ascii(3),
    EOT: ascii(4),
    ENQ: ascii(5),
    ACK: ascii(6),
    BEL: ascii(7),
    BS:  ascii(8),
    HT:  ascii(9),
    LF:  ascii(10),
    VT:  ascii(11),
    FT:  ascii(12),
    CR:  ascii(13),
    SO:  ascii(14),
    SI:  ascii(15),
    DLE: ascii(16),
    DC1: ascii(17),
    DC2: ascii(18),
    DC3: ascii(19),
    DC4: ascii(20),
    NAK: ascii(21),
    SYN: ascii(22),
    ETB: ascii(23),
    CAN: ascii(24),
    EM:  ascii(25),
    SUB: ascii(26),
    ESC: ascii(27),
    FS:  ascii(28),
    GS:  ascii(29),
    RS:  ascii(30),
    US:  ascii(31),
    DEL: ascii(127)
  };

  // Just use jQuery for now.
  WebConsole.$ = jQuery.noConflict();

  // Abstraction for the terminal cursor.
  WebConsole.Cursor = function(x, y, options) {
    this.moveTo(x, y);
    this.configure(options);
  };

  // Move the cursor to the specified X and Y coordinates.
  //
  // If X or Y are falsy, they will be set to 0.
  WebConsole.Cursor.prototype.moveTo = function(x, y) {
    this.x = x || 0;
    this.y = y || 0;
  };

  WebConsole.Cursor.prototype.configure = function(options) {
    $.extend(this.options || (this.options = {}), options || {});
  };

}).call(this);
