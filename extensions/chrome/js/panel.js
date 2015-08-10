var tabId = chrome.devtools.inspectedWindow.tabId;
var port = chrome.runtime.connect({ name: tabId.toString() });
var repl;

// We need to avoid the sandbox of Chrome DevTools via the messaging system.
REPLConsole.request = function(method, url, params, callback) {
  chrome.runtime.sendMessage({
    tabId: tabId,
    type: 'request',
    method: method,
    url: url,
    params: params
  }, callback);
};

// Handle messages from the background script.
port.onMessage.addListener(function(msg) {
  if (msg.type === 'update-session') {
    updateSession(msg);
  } else if (msg.type === 'remove-console') {
    removeConsole();
  }
});

function updateSession(info) {
  if (repl) {
    repl.sessionId  = info.sessionId;
    repl.mountPoint = info.mountPoint;
  } else {
    var options = { sessionId: info.sessionId, mountPoint: info.mountPoint };
    repl = REPLConsole.installInto('console', options);
  }
}

function removeConsole() {
  var script = 'if (REPLConsole && REPLConsole.currentSession) REPLConsole.currentSession.uninstall()';
  chrome.devtools.inspectedWindow.eval(script);
}

port.postMessage({ type: 'session', tabId: tabId });
removeConsole();
