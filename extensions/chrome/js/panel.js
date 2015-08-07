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
  if (msg.type === 'session-id') {
    updateRemotePath(msg.sessionId);
  } else if (msg.type === 'remove-console') {
    removeConsole();
  }
});

function updateRemotePath(sessionId) {
  var remotePath = '__web_console/repl_sessions/' + sessionId;
  if (repl) {
    repl.remotePath = remotePath;
  } else {
    repl = REPLConsole.installInto('console', { remotePath: remotePath });
  }
}

function removeConsole() {
  var script = 'if (REPLConsole && REPLConsole.currentSession) REPLConsole.currentSession.uninstall()';
  chrome.devtools.inspectedWindow.eval(script);
}

port.postMessage({ type: 'session-id', tabId: tabId });
removeConsole();
