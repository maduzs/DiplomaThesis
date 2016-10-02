var JS = function() {

    var a = 0;

    this.init = function(){
        JS_COMMUNICATOR.sendResponse("js: init");
    }

    this.eval = function(param, param2) {
        var random = Math.random() * (500);

        var now = new Date().getTime();
        while(new Date().getTime() < now + random){ /* do nothing */ }

        a++;
        
        //window['JS']['init']();
        //JS_COMMUNICATOR.sendResponse("_______");
        
        JS_COMMUNICATOR.sendResponse("js.eval: " + param + param2);
    }

    this.render = function(){
        var text =
        {
          "uiElements" : [
            {"button": {
              "objectId" : 0,
              "title" : "button1",
              "frame": {
                "x" : 50,
                "y" : 360,
                "width" : 100,
                "height" : 50
              },
              "onClick": "eval",
              "params": [
                {"value" : "test"},
                {"value" : "test2"}
              ]
            }
          }
        ]
        };
        JS_COMMUNICATOR.sendResponse(text);
    }

}
