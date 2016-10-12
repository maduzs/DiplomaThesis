class JS {
    
    constructor(){

        this.button1 = {
            objectId : 0,
            alpha:  0.5,
            title : "button1",
            frame: {
                x : 50,
                y : 360,
                width : 100,
                height : 50
            },
            onClick: "updateElement",
            params : [ "test" ]
            };
        this.button3 = {
            objectId : 30,
            title : "updateElement",
            frame: {
                x : 50,
                y : 300,
                width : 50,
                height : 25
            },
            onClick: "eval",
            params : [ 10.10 , "jsss", 10 ]
        };
        this.button4 = {
            objectId : 40,
            title : "delete",
            frame: {
                x : 50,
                y : 270,
                width : 50,
                height : 25
            },
            onClick: "deleteElement",
            params: [ this.button1, 30 ]
        };
        this.label1 = {
            objectId : 2,
            text : "label1",
            frame : {
                x : 50,
                y : 260,
                width : 220,
                height : 21
            }
        }
        this.button2 = {
            objectId : 20,
            title : "add",
            frame: {
                x : 50,
                y : 330,
                width : 50,
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
        var msg = { uiElements : [ { button : arg }, { button : arg2 }, { label: arg3} ] }
        JS_COMMUNICATOR.addUIElement(msg);
    }
    
    updateElement(param){
        JS_COMMUNICATOR.updateUIElement(param);
    }
    
    deleteElement(arg, arg2){
        JS_COMMUNICATOR.deleteUIElement(arg, arg2);
    }

    render(){
        var text =
        {
            uiElements : [
                { button: this.button1 },
                { button: this.button2 }
            ]
        };

        JS_COMMUNICATOR.sendResponse(text);
    }

};

window.js = new JS();
