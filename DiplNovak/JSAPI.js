class JSAPI {
    
    constructor(aid, iCode){
        this.apiId = aid;
        this.initCode = iCode;
    }
    
    evaluate(id, funcName) {
        
        this.callId = id;
        
        // convert arguments to array
        var args = Array.prototype.slice.call(arguments);
        // slice the first two arguments and call the method with remaining ones
        if (arguments.length > 1){ // 2 ?
            args.splice(0, 2);
            funcName.apply(this, args);
        }
    }
    
    evaluateClass(id, className, funcName){
        
        this.callId = id;

        var args = Array.prototype.slice.call(arguments);
        if (arguments.length > 3){
            args.splice(0, 3);
            window[className][funcName](...args);
        }
        else {
            window[className][funcName]();
        }
    }
    
    sendResponse(content){
        const messageToPost = {'ID': this.callId, 'apiId' : this.apiId, 'msg' : content};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    sendAsyncResponse(content){
        const messageToPost = {'ID': -1, 'apiId' : this.apiId, 'msg' : content};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    registerObject() {
        var args = Array.prototype.slice.call(arguments);
        
        const messageToPost = {'ID': this.initCode, 'apiId' : this.apiId, 'msg' : args.toString()};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    destroy(className) {
        window[className] = null;
        delete window[className]
    }
};
