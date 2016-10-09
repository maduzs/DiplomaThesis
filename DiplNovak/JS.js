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
            onClick: "eval",
            params: [
                 {value : "eval"},
                 {value : 0.2},
                 {value : 10},
                 {value : true}
            ]
        }
    }

    eval(param, param2, param3, param4) {
        JS_COMMUNICATOR.sendAsyncResponse(param + param2 + param3 + param4);
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
