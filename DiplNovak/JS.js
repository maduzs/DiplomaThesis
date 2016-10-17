class JS {
    
    constructor(){
        this.button3 = {
            objectId : 30,
            objectType : "button",
            title : "eval",
            frame: {
                x : 50,
                y : 300,
                width : 100,
                height : 25
            },
            textColor : [0,0,0,1],
            backgroundColor : [255,255,255,1],
            onClick: "eval",
            params : [ 10.10 , "jsss", 10 ]
        };
        this.button1 = {
            objectId : 0,
            objectType : "button",
            alpha:  0.5,
            title : "button1",
            frame: {
                x : 50,
                y : 360,
                width : 100,
                height : 50
            },
            textColor : [0,0,255,1],
            backgroundColor : [0,0,0,1],
            onClick: "updateElement",
            params : [ this.button3 , { objectId: 40, frame: { x : 150, y : 160, width : 80, height : 60 }, alpha: 0.3 }]
        };
        this.button4 = {
            objectId : 40,
            objectType : "button",
            title : "delete",
            frame: {
                x : 50,
                y : 270,
                width : 100,
                height : 25
            },
            onClick: "deleteElement",
            params: [ 40, 30 ]
        };
        this.label1 = {
            objectId : 2,
            objectType : "label",
            text : "label1",
            frame : {
                x : 50,
                y : 160,
                width : 220,
                height : 21
            },
            textColor : [255,255,255,1],
            backgroundColor: [0,0,0,1],
            textAlignment: "center"
        }
        this.button2 = {
            objectId : 20,
            objectType : "button",
            title : "add",
            frame: {
                x : 50,
                y : 330,
                width : 100,
                height : 25
            },
            onClick: "addElement",
            params: [ this.button4, this.button3, this.label1 ]
        };
    }

    eval(param, param2, param3) {
        // apply args??
        JS_COMMUNICATOR.sendAsyncResponse(param, param2, param3);
    }
    
    addElement(arg, arg2, arg3){
        var msg = { uiElements : [ arg,  arg2, arg3 ] }
        JS_COMMUNICATOR.addUIElement(msg);
    }
    
    updateElement(param, param2, param3){
        param = this.label1
        param.text = ""
        param.frame = {
            x : 150,
            y : 330,
            width : 100,
            height : 25
        }
        for (var i=0; i<10; i++){
            param.text += "T"
            var now = new Date().getTime();
            while(new Date().getTime() < now + 50){
                // do nothing
            }
            if (param.text.length > 5){
                param.text = "";
            }
            JS_COMMUNICATOR.updateUIElement( param);
        }
        JS_COMMUNICATOR.updateUIElement(param2, param3);
        
    }
    
    deleteElement(arg, arg2){
        JS_COMMUNICATOR.deleteUIElement(arg, arg2);
    }

    render(){
        var text =
        {
            uiElements : [ this.button1, this.button2 ]
        };

        JS_COMMUNICATOR.sendResponse(text);
    }

};

window.js = new JS();
