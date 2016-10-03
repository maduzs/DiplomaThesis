var JS = function() {

    var button1 = {
        objectId : 0,
        title : "button1",
        frame: {
            x : 50,
            y : 360,
        width : 100,
        height : 50
        },
        onClick: "eval",
        params: [
             {value : "test"},
             {value : "test2"}
        ]
    }
    
    this.init = function(){
        JS_COMMUNICATOR.sendResponse("js: init");
    }

    this.eval = function(param, param2) {
        JS_COMMUNICATOR.sendResponse("js.eval: " + param + param2);
    }

    this.render = function(){
        var text =
        {
            uiElements : [
                { button: button1 }
            ]
        };
        JS_COMMUNICATOR.sendResponse(text);
    }

}
