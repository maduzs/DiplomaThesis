var id3 = 'Z';
messageToPost = {'ID': id3, 'msg' : 'a= ' + a.toString()};
window.webkit.messageHandlers.buttonClicked.postMessage(messageToPost);