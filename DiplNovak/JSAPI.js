var JSAPI = function(){
    
    var callId = 0;
    var objects = [];
    
    this.evaluate = function (id, funcName) {
        
        callId = id;
        
        // convert arguments to array
        var args = Array.prototype.slice.call(arguments);
        // slice the first two arguments and call the method with remaining ones
        if (arguments.length > 1){ // 2 ?
            args.splice(0, 2);
            funcName.apply(this, args);
        }
    }
    
    this.evaluateClass = function (id, className, funcName){
        callId = id;

        var args = Array.prototype.slice.call(arguments);
        if (arguments.length > 3){
            args.splice(0, 3);
            window[className][funcName].apply(this, args);
        }
        else {
            window[className][funcName]();
        }
        
        
        //JSON possible?
        //var obj = JSON.parse(msg.data);
        /*if (obj.act == "invoke") {
            eval(obj.target).apply(window,obj.args);
        }*/
    }
    
    this.init = function (className) {
        var args = Array.prototype.slice.call(arguments);
        var init = 'init';
        if (arguments.length > 1){
            args.splice(0, 1);
            window[className]['init'].apply(this, args);
        }
        else{
            window[className][init]();
        }
        
    }
    
    this.render = function (className) {
        var args = Array.prototype.slice.call(arguments);
        if (arguments.length > 1){
            args.splice(0, 1);
            window[className]['render'].apply(this, args);
        }
        else {
            window[className]['render']();
        }
    }
    

    
    this.registerObject = function(className) {
        window[className] = new window[className]();
    }
    
    this.sendResponse = function(content){
        var messageToPost = {'ID': callId, 'msg' : content};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    this.destroy = function (className) {
        window[className] = null;
        delete window[className]
    }
};