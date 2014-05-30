// $(function() {
//   var ERROR_CLASS = 'jquery-console-message-error';

//   var $console = $('#console');
//   var instance = $console.console({
//     autofocus: true,
//     promptLabel: $console.data('initial-prompt'),
//     animateScroll: true,
//     commandHandle: function(line, report) {
//       $.ajax({
//         url: $console.data('remote-path'),
//         type: 'PUT',
//         dataType: 'json',
//         data: { input: line },
//         success: function(response) {
//           instance.promptLabel(response.prompt);
//           report([{msg: response.output}]);
//         },
//         error: function(xhr) {
//           report([{msg: xhr.responseJSON.error, className: ERROR_CLASS}]);
//         }
//       });
//     }
//   });
// });

var consoleEl = document.getElementById('console');
new REPLConsole().install(consoleEl, {
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
