var a = 1;
var id = 'A';
var messageToPost = {'ID': id, 'msg' : 'a= ' + a.toString()};

window.webkit.messageHandlers.buttonClicked.postMessage(messageToPost);