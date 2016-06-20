var a = 1;
var id = 10;
var messageToPost = {'ID': id, 'msg' : 'a= ' + a.toString()};

window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);