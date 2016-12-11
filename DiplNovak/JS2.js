class JS2 {

    constructor() {
        
        this.textField1 = {
            objectId : 3,
            objectType : "textField",
            text : "textField1",
            frame : {
                x : 50,
                y : 190,
                width : 220,
                height : 30
            }
        }
        
        this.textView1 = {
            objectId : 4,
            objectType : "textView",
            text : "textView1",
            frame : {
                x : 50,
                y : 110,
                width : 220,
                height : 50
            }
        }
        
        this.button2 = {
            objectId : 1,
            objectType : "button",
            title : "button2" ,
            frame : {
                x : 170,
                y : 360,
                width : 100,
                height : 50
            },
        onClick: "updateElement",
        params: [ this.textField1 ]
        }
    }

    eval2(param, param2) {

        JS_COMMUNICATOR.sendAsyncResponse("js2.eval2: " + param + param2);
    }
    
    updateElement(param){
        param.text = ""
        var fx = 150;
        var addition = 2;
        param.frame = {
            x : fx,
            y : 130,
            width : 50,
            height : 50
        }
        for (var i=0; i<150; i++){
            if (i % 10 == 0){
                param.text += "C"
            }
            if (fx > 200 && addition > 0){
                addition = addition * -1;}
            if (fx < 100 && addition < 0){
                addition = addition * -1;
            }
            
            fx += addition;
            
            param.frame = {
                x : fx,
                y : 330,
                width : 100,
                height : 25
            }
            var now = new Date().getTime();
            while(new Date().getTime() < now + 50){
                // do nothing
            }
            if (param.text.length > 5){
                param.text = "";
            }
            JS_COMMUNICATOR.updateUIElement(param);
        }
        JS_COMMUNICATOR.deleteUIElement(4);
    }

    
    deleteElement(arg, arg2){
        JS_COMMUNICATOR.deleteUIElement(arg, arg2);
    }

    render() {
        var text =
        {
            uiElements : [ this.button2, this.textField1 , this.textView1 ]
        };
        
        JS_COMMUNICATOR.sendResponse(text);
    }
}

window.js2 = new JS2();
JS_COMMUNICATOR.registerObject("js2");

