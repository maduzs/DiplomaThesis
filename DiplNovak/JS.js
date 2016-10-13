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
            onClick: "updateElement",
            params : [ this.button3 , { objectId: 40, title: "D"}, {objectId: 0, alpha: 1.0}]
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
            }
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
        param.title = "T"
        JS_COMMUNICATOR.updateUIElement( param , param2, param3);
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
