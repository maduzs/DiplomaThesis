class JSTEST {
    
    constructor(){
        this.buttonTest = {
            objectId : 1337,
            objectType : "button",
            title : "Test",
            /*frame: {
                x : 50,
                y : 330,
                width : 100,
                height : 125
            },*/
            constraints : [
                           { anchor : "centerX", constant : 0 },
                           { anchor : "centerY", constant : 0 },
                           { anchor : "width", constant : 100},
                           { anchor : "height", constant : 50},
                           ],
        onClick: "testCalc",
        params: []
        };
    }
    
    addElement(arg, arg2, arg3){
        var msg = { uiElements : [ arg,  arg2, arg3 ] }
        JS_COMMUNICATOR.addUIElement(msg);
    }
    
    test(){
        var date = new Date()
        JS_COMMUNICATOR.sendAsyncResponse("Start: " + date.getTime());
        var uiElements = []
        var x = 10;
        var y = 10;
        for (var i=0 ;i<1000; i++){
            var index = 1337 + (i + 1);
            var buttonTest = {
                objectId : index,
                objectType : "button",
                title : "Test " + index,
                /*frame: {
                    x : 50,
                    y : 330,
                    width : 100,
                    height : 125
                },*/
                constraints : [
                               { anchor : "top", constant : y, toObjectId : (index-1) },
                               { anchor : "leading", constant : 0, toObjectId : (index-1) },
                               { anchor : "width", constant : 100},
                               { anchor : "height", constant : 50},
                               ],
            onClick: "testClick",
            params: [index ]
            }
            uiElements.push(buttonTest);
        }
        var msg = { uiElements }
        JS_COMMUNICATOR.addUIElement(msg);
    }
    
    testCalc(){
        var uiElements = []
        var buttonTest = {
            objectId : 80,
            objectType : "button",
            title : "Test ",
            frame: {
             x : 50,
             y : 430,
             width : 100,
             height : 125
             },
        onClick: "testCalcExec",
        params: [{ objectId: 80,
                     title : 80}]
        }
        uiElements.push(buttonTest);
        
        var msg = { uiElements }
        JS_COMMUNICATOR.addUIElement(msg);
        
    }
    
    testCalcExec(params){
        var now = new Date().getTime();
        params.title = String(now);
        JS_COMMUNICATOR.updateUIElement(params);
    }
    
    fibonacci(){
        var date = new Date();
        var log = ("Start: " + date.getTime());
        var i;
        var fib = [];
        
        fib[0] = 0;
        fib[1] = 1;
        for(i=2; i<=100000000; i++){
            fib[i] = fib[i-2] + fib[i-1];
        }
        var date = new Date();
        log += (" End: " + date.getTime());
        JS_COMMUNICATOR.sendAsyncResponse(log + " " + fib.length);
    }
    
    testClick(param){
        JS_COMMUNICATOR.sendAsyncResponse("testClick" + param);
    }
    
    render(){
        /*var y = 50;
        var uiElements = []
        var x = Math.floor((Math.random() * 100) + 100);
        for (var i=0 ;i<100; i++){
            var index = 1337 + (i + 1);
            var buttonTest = {
                objectId : index,
                objectType : "button",
                title : "Test " + index,
                constraints : [
                               { anchor : "top", constant : y+i, toObjectId : (index-1) },
                               { anchor : "leading", constant : x },
                               { anchor : "width", constant : 100},
                               { anchor : "height", constant : 50},
                               ],
            onClick: "testClick",
            params: [index ]
            }
            uiElements.push(buttonTest);
        }
        var msg = { uiElements }
        */
        var text =
        {
            uiElements : [ this.buttonTest]
        };
        
        JS_COMMUNICATOR.sendResponse(text);
    }
    
};

window.jstest = new JSTEST();
JS_COMMUNICATOR.registerObject("jstest");
