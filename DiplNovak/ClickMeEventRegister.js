var button = document.getElementById("clickMeButton");
button.addEventListener("click", function() {
            var messageToPost = {'ButtonId':'clickMeButton'};
            window.webkit.messageHandlers.buttonClicked.postMessage(messageToPost);
                        },false);