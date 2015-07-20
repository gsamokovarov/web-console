var tabInfo = {};
var ports = {};

initPanelMessage();
initReqRes();
initHttpListener();
initNavListener();

function panelMessage(tabId, type, msg) {
  msg = msg || {};
  msg.type = type;
  if (ports[tabId]) {
    ports[tabId].postMessage(msg);
  }
}

function sendSessionId(tabId) {
  panelMessage(tabId, 'session-id', { sessionId: tabInfo[tabId].sessionId });
}

function removeConsole(tabId) {
  panelMessage(tabId, 'remove-console');
}

function initPanelMessage() {
  chrome.runtime.onConnect.addListener(onConnect);

  function handleMessage(msg) {
    if (msg.type === 'session-id') {
      sendSessionId(msg.tabId);
    }
  }

  function onConnect(newPort) {
    ports[newPort.name] = newPort;
    newPort.onMessage.addListener(handleMessage);
  }
}

function initReqRes() {
  chrome.runtime.onMessage.addListener(handleMessage);

  function handleMessage(req, sender, sendResponse) {
    if (req.type === 'request') {
      var url = tabInfo[req.tabId].remoteHost + '/' + req.url;
      REPLConsole.request(req.method, url, req.params, function(xhr) {
        sendResponse({ status: xhr.status, responseText: xhr.responseText });
      });
    }
    return true;
  }
}

function initHttpListener() {
  var requestFilter = {
    types: [ 'main_frame' ],
    urls: [ 'http://*/*', 'https://*/*' ]
  };

  // Fired when a request is completed.
  chrome.webRequest.onCompleted.addListener(
    onResponse, requestFilter, [ 'responseHeaders' ]
  );

  function getHeaders(details) {
    return details.responseHeaders.reduce(reduceFunc, {});
  }

  function reduceFunc(obj, header) {
    obj[header.name] = header.value;
    return obj;
  }

  function onResponse(details) {
    var headers = getHeaders(details);
    var sessionId;
    if (sessionId = headers['X-Web-Console-Session-Id']) {
      tabInfo[details.tabId] = {
        sessionId: sessionId,
        remoteHost: details.url.match(/([^:]+:\/\/[^\/]+)\/?/)[1]
      };
    }
  }
}

function initNavListener() {
  // Fired when a document is completely loaded and initialized.
  chrome.webNavigation.onCompleted.addListener(function(details) {
    if (filter(details)) {
      sendSessionId(details.tabId);
      removeConsole(details.tabId);
    }
  });

  function filter(details) {
    return details.frameId === 0 && tabInfo[details.tabId];
  }
}
