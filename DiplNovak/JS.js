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
            onClick: "eval"
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
            onClick: "updateElement"
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
            /*params: [
                {value: 0}
            ]*/
        };
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
            params: [
                 {value: this.button4}
            ]
        };
    }

    eval(param, param2, param3, param4) {
        JS_COMMUNICATOR.sendAsyncResponse("test" + param2 + param3 + param4);
    }
    
    addElement(arg){
        var msg = { uiElements : [ { button : arg } ] }
        JS_COMMUNICATOR.addUIElement(msg);
    }
    
    updateElement(){
        JS_COMMUNICATOR.updateUIElement();
    }
    
    deleteElement(){
        JS_COMMUNICATOR.deleteElement(this.button1);
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
