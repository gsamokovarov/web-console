var consoleDiv = document.getElementById('console');
var replConsole = new REPLConsole({
  promptLabel: consoleDiv.dataset.initialPrompt,
  commandHandle: function(line) {
    var _this = this;
    var xhr = new XMLHttpRequest();
    var url = consoleDiv.dataset.remotePath;
    var params = "input=" + encodeURIComponent(line);

    xhr.open("PUT", url, true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
    xhr.send(params);

    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        var response = JSON.parse(xhr.responseText);
        _this.writeOutput(response.output);
      }
    }
  }
});

replConsole.install(consoleDiv);
