$(function() {
  var ERROR_CLASS = 'jquery-console-message-error';

  var $console = $('#console');
  var instance = $console.console({
    autofocus: true,
    promptLabel: "",
    commandHandle: function(line) {
      $.ajax({
        url: $console.data('input-path'),
        type: 'PUT',
        data: { input: line }
      });
    },
    cancelHandle: function() {
      $.ajax({
        url: $console.data('interrupt-path'),
        type: 'PUT'
      });
    }
  });

  (function pollForPendingOutput() {
    $.ajax({
      url: $console.data('pending-output-path'),
      type: 'GET',
      dataType: 'json',
      success: function(response) {
        if (response.output != null) instance.report(response.output);
        setTimeout(pollForPendingOutput, 500);
      },
      error: function(xhr) {
        instance.report([ { msg: xhr.responseJSON.error, className: ERROR_CLASS } ]);
      }
    });
  }).call(this);
});
