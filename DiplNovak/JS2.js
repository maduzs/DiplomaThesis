class JS2 {

    constructor() {
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
            onClick: "eval2",
            params: [ "test3", "test4" ]
        }
        
        this.textField1 = {
            objectId : 3,
            objectType : "textField",
            text : "textField1",
            frame : {
                x : 50,
                y : 180,
                width : 220,
                height : 30
            }
        }
        
        /*this.textView1 = {
            objectId : 4,
            objectType : "textView",
            text : "textView1",
            frame : {
                x : 50,
                y : 80,
                width : 320,
                height : 90
            }
        }*/
    }

    eval2(param, param2) {
        /*var random = Math.random() * (50);

        var now = new Date().getTime();
        while(new Date().getTime() < now + random){
            // do nothing
        }
        */

        JS_COMMUNICATOR.sendAsyncResponse("js2.eval2: " + param + param2);
    }

    render() {
        var text =
        {
            uiElements : [ /*this.button2, this.textField1 , this.textView1 */]
        };
        
        JS_COMMUNICATOR.sendResponse(text);
    }
}

window.js2 = new JS2();
JS_COMMUNICATOR.registerObject("js");

