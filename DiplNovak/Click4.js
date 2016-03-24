var a = 1;
var id = 'A';
var messageToPost = {'ID': id, 'msg' : a.toString()};

window.webkit.messageHandlers.button2Clicked.postMessage(messageToPost);