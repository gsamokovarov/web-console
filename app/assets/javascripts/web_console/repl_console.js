(function() {
  // DOM helpers
  function hasClass(el, className) {
    var regex = new RegExp('(?:^|\\s)' + className + '(?!\\S)', 'g');
    return el.className.match(regex);
  }

  function addClass(el, className) {
    el.className += " " + className;
  }

  function removeClass(el, className) {
    var regex = new RegExp('(?:^|\\s)' + className + '(?!\\S)', 'g');
    el.className = el.className.replace(regex, '');
  }

  function removeAllChildren(el) {
    while (el.firstChild) {
      el.removeChild(el.firstChild);
    }
  }

  // REPLConsole Constructor
  function REPLConsole(index) {
    var previousCommands = JSON.parse(localStorage.getItem("web_console_previous_commands"));
    if(previousCommands === null) {
      localStorage.setItem("web_console_previous_commands", JSON.stringify([]));
      previousCommands = [];
    }

    this.previousCommandOffset = previousCommands.length;
  }

  REPLConsole.prototype.install = function(container, config) {
    this.prompt = config && config.promptLabel ? config.promptLabel : ' >>';
    this.commandHandle = config && config.commandHandle ? config.commandHandle : function() { return this; }

    var _this = this;
    document.onkeydown = function(ev) {
      if (_this.focused) {
        _this.onKeyDown(ev);
      }
    };

    document.onkeypress = function(ev) {
      if (_this.focused) {
        _this.onKeyPress(ev);
      }
    };

    document.addEventListener('mousedown', function(ev) {
      var el = ev.target || ev.srcElement;
      if (el) {
        do {
          if (el === container) {
            _this.focus();
            return;
          }
        } while (el = el.parentNode);

        _this.blur();
      }
    });

    // Render the console.
    this.inner = document.createElement('div');
    this.inner.className = "console-inner";
    this.newPromptBox();
    container.appendChild(this.inner);
  };

  REPLConsole.prototype.focus = function() {
    this.focused = true;
    if (! hasClass(this.inner, "console-focus")) {
      addClass(this.inner, "console-focus");
    }
  };

  REPLConsole.prototype.blur = function() {
    this.focused = false;
    removeClass(this.inner, "console-focus");
  };

  /**
   * Add a new empty prompt box to the console.
   */
  REPLConsole.prototype.newPromptBox = function() {
    // Remove the caret from previous prompt box if any.
    if (this.promptInput) {
      this.removeCaretFromPrompt();
    }

    var promptBox = document.createElement('div');
    promptBox.className = "console-prompt-box";
    var promptLabel = document.createElement('span');
    promptLabel.className ="console-prompt-label";
    promptLabel.style.display = "inline";
    promptLabel.innerHTML = this.prompt;
    var promptInput = document.createElement('span');
    promptInput.className = "console-prompt";
    promptBox.appendChild(promptLabel);
    promptBox.appendChild(promptInput);
    this.inner.appendChild(promptBox);

    this.promptLabel = promptLabel;
    this.promptInput = promptInput;
    this.setInput("");
  };

  /**
   * Remove the caret from the prompt box,
   * mainly before adding a new prompt box.
   * For simplicity, just re-render the prompt box
   * with caret position -1.
   */
  REPLConsole.prototype.removeCaretFromPrompt = function() {
    this.setInput(this._input, -1);
  };

  REPLConsole.prototype.setInput = function(input, caretPos) {
    if (typeof caretPos === 'undefined') {
      this._caretPos = input.length;
    } else {
      this._caretPos = caretPos;
    }
    this._input = input;
    this.renderInput();
  }

  /**
   * Render the input prompt. This is called whenever
   * the user input changes, sometimes not very efficient.
   */
  REPLConsole.prototype.renderInput = function() {
    // Clear the current input.
    removeAllChildren(this.promptInput);

    var promptCursor = document.createElement('span');
    promptCursor.className = "console-cursor";
    var before, current, master;

    if (this._caretPos < 0) {
      before = this._input;
      current = after = "";
    } else if (this._caretPos === this._input.length) {
      before = this._input;
      current = "\u00A0";
      after = "";
    } else {
      before = this._input.substring(0, this._caretPos);
      current = this._input.charAt(this._caretPos);
      after = this._input.substring(this._caretPos + 1, this._input.length);
    }

    this.promptInput.appendChild(document.createTextNode(before));
    promptCursor.appendChild(document.createTextNode(current));
    this.promptInput.appendChild(promptCursor);
    this.promptInput.appendChild(document.createTextNode(after));
  };

  REPLConsole.prototype.writeOutput = function(output) {
    var consoleMessage = document.createElement('div');
    consoleMessage.className = "console-message";
    consoleMessage.innerHTML = output;
    this.inner.appendChild(consoleMessage);
    this.newPromptBox();
  };

  REPLConsole.prototype.onEnterKey = function() {
    var input = this._input;
    if(input != "" && input !== undefined) {
      var previousCommands = JSON.parse(localStorage.getItem("web_console_previous_commands"));
      this.previousCommandOffset = previousCommands.push(input);
      if(previousCommands.length > 100) {
        previousCommands.splice(0, 1);
      }
      localStorage.setItem("web_console_previous_commands", JSON.stringify(previousCommands));
    }

    this.commandHandle(input);
  };

  REPLConsole.prototype.onNavigateHistory = function(direction) {
    this.previousCommandOffset += direction;
    var previousCommands = JSON.parse(localStorage.getItem("web_console_previous_commands"));

    if(this.previousCommandOffset < 0) {
      this.previousCommandOffset = -1;
      this.setInput("");
      return;
    }

    if(this.previousCommandOffset >= previousCommands.length) {
      this.previousCommandOffset = previousCommands.length;
      this.setInput("");
      return;
    }

    this.setInput(previousCommands[this.previousCommandOffset]);
  };

  /**
   * Handle control keys like up, down, left, right.
   */
  REPLConsole.prototype.onKeyDown = function(ev) {
    switch (ev.keyCode) {
      case 13:
        // Enter key
        this.onEnterKey();
        ev.preventDefault();
        break;
      case 38:
        // Up arrow
        this.onNavigateHistory(-1);
        ev.preventDefault();
        break;
      case 40:
        // Down arrow
        this.onNavigateHistory(1);
        ev.preventDefault();
        break;
      case 37:
        // Left arrow
        var caretPos = this._caretPos > 0 ? this._caretPos - 1 : this._caretPos;
        this.setInput(this._input, caretPos);
        ev.preventDefault();
        break;
      case 39:
        // Right arrow
        var length = this._input.length;
        var caretPos = this._caretPos < length ? this._caretPos + 1 : this._caretPos;
        this.setInput(this._input, caretPos);
        ev.preventDefault();
        break;
      case 8:
        // Delete
        this.deleteAtCurrent();
        ev.preventDefault();
        break;
      default:
        break;
    }

    ev.stopPropagation();
  };

  /**
   * Delete a character at the current position.
   */
  REPLConsole.prototype.deleteAtCurrent = function() {
    if (this._caretPos > 0) {
      var caretPos = this._caretPos - 1;
      var before = this._input.substring(0, caretPos);
      var after = this._input.substring(this._caretPos, this._input.length);
      this.setInput(before + after, caretPos);
    }
  };

  /**
   * Insert a character at the current position.
   */
  REPLConsole.prototype.insertAtCurrent = function(char) {
    var before = this._input.substring(0, this._caretPos);
    var after = this._input.substring(this._caretPos, this._input.length);
    this.setInput(before + char + after, this._caretPos + 1);
  };

  /**
   * Handle input key press.
   */
  REPLConsole.prototype.onKeyPress = function(ev) {
    var keyCode = ev.keyCode || e.which;
    this.insertAtCurrent(String.fromCharCode(keyCode));
    ev.stopPropagation();
    ev.preventDefault();
  };

  window.REPLConsole = REPLConsole;
})();
