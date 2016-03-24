var a = 1;
var id = 'X';
var messageToPost = {'ID': id, 'msg' : a.toString()};

window.webkit.messageHandlers.buttonClicked.postMessage(messageToPost);