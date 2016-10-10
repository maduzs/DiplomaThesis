class JS {
    
    constructor(){
        this.button1 = {
            objectId : 0,
            title : "button1",
            frame: {
                x : 50,
                y : 360,
                width : 100,
                height : 50
            },
            onClick: "eval"
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
            onClick: "addElement"
        }
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
        }
        this.button4 = {
            objectId : 40,
            title : "delete",
            frame: {
                x : 50,
                y : 270,
                width : 50,
                height : 25
            },
            onClick: "deleteElement"
        }
    }

    eval(param, param2, param3, param4) {
        JS_COMMUNICATOR.sendAsyncResponse("test" + param2 + param3 + param4);
    }
    
    addElement(){
        JS_COMMUNICATOR.addUIElement();
    }
    
    updateElement(){
        JS_COMMUNICATOR.updateUIElement();
    }
    
    deleteElement(){
        JS_COMMUNICATOR.deleteElement();
    }

    render(){
        var text =
        {
            uiElements : [
                { button: this.button1 }
            ]
        };

        JS_COMMUNICATOR.sendResponse(text);
    }

};

window.js = new JS();
