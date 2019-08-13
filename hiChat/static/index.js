function setupWebViewJavascriptBridge(callback) {
  if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
  if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
  window.WVJBCallbacks = [callback];
  var WVJBIframe = document.createElement('iframe');
  WVJBIframe.style.display = 'none';
  WVJBIframe.src = 'https://__bridge_loaded__';
  document.documentElement.appendChild(WVJBIframe);
  setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

function getVersion(completion) {
  setupWebViewJavascriptBridge(function(bridge) {
    bridge.callHandler('getVersion', null, function responseCallback(responseData) {
      if (completion) {
        completion(responseData)
      }
    })
  })
}

function updateVersion(completion) {
  setupWebViewJavascriptBridge(function(bridge) {
    bridge.callHandler('updateVersion', null, function responseCallback(responseData) {
      if (completion) {
        completion(responseData)
      }
    })
  })
}

function getAppName(completion) {
  setupWebViewJavascriptBridge(function(bridge) {
    bridge.callHandler('getAppName', null, function responseCallback(responseData) {
      if (completion) {
        completion(responseData)
      }
    })
  })
}
