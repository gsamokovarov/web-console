$(function() {
  var ERROR_CLASS = 'jquery-console-message-error';

  var $console = $('#console');
  var instance = $console.console({
    autofocus: true,
    promptLabel: $console.data('initial-prompt'),
    commandHandle: function(line, report) {
      $.ajax({
        url: $console.data('remote-path'),
        type: 'PUT',
        dataType: 'json',
        data: { input: line },
        success: function(response) {
          instance.promptLabel(response.prompt);
          report([{msg: response.output}]);
        },
        error: function(xhr) {
          report([{msg: xhr.responseJSON.error, className: ERROR_CLASS}]);
        }
      });
    }
  });
});
