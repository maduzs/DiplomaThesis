var JS2 = function() {
    
    var a = 0;
    
    this.init = function(){
        JS_COMMUNICATOR.sendResponse("testClass: init");
    }
    
    this.eval = function(param, param2) {
        var random = Math.random() * (500);
        
        var now = new Date().getTime();
        while(new Date().getTime() < now + random){ /* do nothing */ }
        
        a++;
        JS_COMMUNICATOR.sendResponse("testClass.eval: " + param + param2);
    }
    
    this.eval2 = function(param, param2){
        var random = Math.random() * (500);
        
        var now = new Date().getTime();
        while(new Date().getTime() < now + random){ /* do nothing */ }
        
        a++;
        JS_COMMUNICATOR.sendResponse("testClass.eval2: " + param + param2);
    }
    
    this.render = function(){
        var text =
        { 
            "uiElements" : [
                { "button": { "title" : "button1" , "onClick": "eval", "params": [ {"value" : "test"}, {"value" : "test2"} ] }},
                { "button": { "title" : "button2" , "onClick": "eval2", "params": [ {"value" : "test3"}, {"value" : "test4"} ] }},
                { "label": {"text" : "label1"} },
                { "textfield": {"text" : "textField1" } }
            ]
        };
        
        JS_COMMUNICATOR.sendResponse(text);
    }
    
}

