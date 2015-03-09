// Try intercept traces links in Rails 4.2.
var traceFrames = document.getElementsByClassName('trace-frames');
var selectedFrame, currentSource = document.getElementById('frame-source-0');

// Add click listeners for all stack frames
for (var i = 0; i < traceFrames.length; i++) {
  traceFrames[i].addEventListener('click', function(e) {
    e.preventDefault();
    var target = e.target;
    var frameId = target.dataset.frameId;

    // Change the binding of the console.
    changeBinding(frameId, function() {
      if (selectedFrame) {
        selectedFrame.className = selectedFrame.className.replace("selected", "");
      }

      target.className += " selected";
      selectedFrame = target;
    });

    // Change the extracted source code
    changeSourceExtract(frameId);
  });
}

function changeBinding(frameId, callback) {
  var consoleEl = document.getElementById('console');
  if (! consoleEl) { return; }
  var url = consoleEl.dataset.remotePath + "/trace";
  var params = "frame_id=" + encodeURIComponent(frameId);
  var xhr = new XMLHttpRequest();
  xhr.open("POST", url, true);
  xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  xhr.send(params);
  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      callback();
    }
  }
}

function changeSourceExtract(frameId) {
  var el = document.getElementById('frame-source-' + frameId);
  if (currentSource && el) {
    currentSource.className += " hidden";
    el.className = el.className.replace(" hidden", "");
    currentSource = el;
  }
}

// Push the error page body upwards the size of the console.
//
// While, I wouldn't like to do that on every custom page (so I don't screw
// user's layouts), I think a lot of developers want to see all of the content
// on the default Rails error page.
//
// Since it's quite special as is now, being a bit more special in the name of
// better user experience, won't hurt.
document.addEventListener('DOMContentLoaded', function() {
  var consoleElement = document.getElementById('console');
  var resizerElement = document.getElementById('resizer')
  var containerElement = document.getElementById('container');

  function setContainerElementBottomMargin(pixels) {
    containerElement.style.marginBottom = pixels + 'px';
  }

  var currentConsoleElementHeight = consoleElement.offsetHeight;
  setContainerElementBottomMargin(currentConsoleElementHeight);

  resizerElement.addEventListener('mousedown', function(event) {
    function recordConsoleElementHeight(event) {
      resizerElement.removeEventListener('mouseup', recordConsoleElementHeight);

      var currentConsoleElementHeight = consoleElement.offsetHeight;
      setContainerElementBottomMargin(currentConsoleElementHeight);
    }

    resizerElement.addEventListener('mouseup', recordConsoleElementHeight);
  });
});
