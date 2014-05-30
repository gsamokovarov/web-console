(function() {
  function REPLConsole(index) {
    var previousCommands = JSON.parse(localStorage.getItem("web_console_previous_commands"));
    if(previousCommands === null) {
      localStorage.setItem("web_console_previous_commands", JSON.stringify([]));
      previousCommands = [];
    }

    this.previousCommandOffset = previousCommands.length;
  }

  REPLConsole.prototype.install = function(container, config) {
    this.focused = false;
    this._prompt = config && config.promptLabel ? config.promptLabel : ' >>';
    this.commandHandle = config && config.commandHandle ? config.commandHandle : function() { return this; }
    this.inner = document.createElement('div');
    this.inner.className = "console-inner";
    this.newPromptBox();

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
    container.appendChild(this.inner);
  };

  REPLConsole.prototype.focus = function() {
    this.focused = true;
  };

  REPLConsole.prototype.blur = function() {
    this.focused = false;
  };

  REPLConsole.prototype.newPromptBox = function() {
    var promptBox = document.createElement('div');
    promptBox.className = "console-prompt-box";
    var promptLabel = document.createElement('span');
    promptLabel.className ="console-prompt-label";
    promptLabel.style.display = "inline";
    var promptEl = document.createElement('span');
    promptEl.className = "console-prompt";
    promptBox.appendChild(promptLabel);
    promptBox.appendChild(promptEl);
    this.inner.appendChild(promptBox);
    this.promptLabel = promptLabel;
    this.promptEl = promptEl;
    this.setPrompt(this._prompt);
  };

  REPLConsole.prototype.setPrompt = function(prompt) {
    this._prompt = prompt;
    this.promptLabel.innerHTML = prompt;
  };

  REPLConsole.prototype.getInput = function() {
    return this.promptEl.innerHTML;
  };

  REPLConsole.prototype.setInput = function(text) {
    this.promptEl.innerHTML = text;
  };

  REPLConsole.prototype.writeOutput = function(output) {
    var consoleMessage = document.createElement('div');
    consoleMessage.className = "console-message";
    consoleMessage.innerHTML = output;
    this.inner.appendChild(consoleMessage);
    this.newPromptBox();
  };

  REPLConsole.prototype.onEnterKey = function() {
    var text = this.getInput();
    if(text != "" && text !== undefined) {
      var previousCommands = JSON.parse(localStorage.getItem("web_console_previous_commands"));
      this.previousCommandOffset = previousCommands.push(text);
      if(previousCommands.length > 100) {
        previousCommands.splice(0, 1);
      }
      localStorage.setItem("web_console_previous_commands", JSON.stringify(previousCommands));
    }

    this.commandHandle(text);
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
        ev.preventDefault()
        break;
      case 40:
        // Down arrow
        this.onNavigateHistory(1);
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
    var text = this.getInput().slice(0, -1);
    this.setInput(text);
  };

  /**
   * Handle input key press.
   */
  REPLConsole.prototype.onKeyPress = function(ev) {
    var keyCode = ev.keyCode || e.which;
    var text = this.getInput() + String.fromCharCode(keyCode);
    this.setInput(text);

    ev.stopPropagation();
    ev.preventDefault();
  };

  window.REPLConsole = REPLConsole;
})();
