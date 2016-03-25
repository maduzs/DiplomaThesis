var a = 1;
var id = 'X';
var messageToPost = {'ID': id, 'msg' : 'restart'};

window.webkit.messageHandlers.buttonClicked.postMessage(messageToPost);