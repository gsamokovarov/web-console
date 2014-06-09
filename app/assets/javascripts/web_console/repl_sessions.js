var consoleEl = document.getElementById('console');
var replConsole = new REPLConsole({
  promptLabel: consoleEl.dataset.initialPrompt,
  commandHandle: function(line) {
    var _this = this;
    var xhr = new XMLHttpRequest();
    var url = consoleEl.dataset.remotePath;
    var params = "input=" + line;

    xhr.open("PUT", url, true);
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr.send(params);

    xhr.onreadystatechange = function() {
      if(xhr.readyState == 4 && xhr.status == 200) {
        var response = JSON.parse(xhr.responseText);
        _this.writeOutput(response.output);
      }
    }
  }
});

replConsole.install(consoleEl);
