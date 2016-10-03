var JS2 = function() {

    var button2 = {
        objectId : 1,
        title : "button2" ,
        frame : {
            x : 170,
            y : 360,
            width : 100,
            height : 50
        },
        onClick: "eval2",
        params: [
             { value : "test3"},
             { value : "test4"}
        ]
    }
    
    var label1 = {
        objectId : 2,
        text : "label1",
        frame : {
            x : 50,
            y : 260,
            width : 220,
            height : 21
        }
    }
    
    var textField1 = {
        objectId : 3,
        text : "textField1",
        frame : {
            x : 50,
            y : 280,
            width : 220,
            height : 30
        }
    }

    this.init = function(){
        JS_COMMUNICATOR.sendResponse("testClass: init");
    }

    this.eval2 = function(param, param2){
        var random = Math.random() * (50);

        var now = new Date().getTime();
        while(new Date().getTime() < now + random){ /* do nothing */ }

        JS_COMMUNICATOR.sendResponse("js2.eval2: " + param + param2);
    }

    this.render = function(){
        var text =
        {
            uiElements : [
                { button: button2 },
                { label: label1 },
                { textfield: textField1 }
            ]
        };
        
        JS_COMMUNICATOR.sendResponse(text);
    }

}
