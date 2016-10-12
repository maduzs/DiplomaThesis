class JSAPI {
    
    constructor(aid, callNames, codesString){
        this.apiId = aid;
        
        this.call1 = callNames[0];
        this.call2 = callNames[1];
        this.call3 = callNames[2];
        
        this.initCode = codesString[0];
        this.asyncCode = codesString[1];
        this.addCode = codesString[2];
        this.updateCode = codesString[3];
        this.deleteCode = codesString[4];
    }
    
    evaluateClass(id, className, funcName){
        
        this.callId = id;
        this.className = className;

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
        const messageToPost = {[this.call1] : this.callId, [this.call2] : this.apiId, [this.call3] : content};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    sendAsyncResponse(){
        var args = Array.prototype.slice.call(arguments);
        const messageToPost = {[this.call1] : this.asyncCode, [this.call2] : this.apiId, [this.call3] :  args };
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    registerObject() {
        var args = Array.prototype.slice.call(arguments);

        const messageToPost = {[this.call1] : this.initCode, [this.call2] : this.apiId, [this.call3] : args.toString()};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    addUIElement(elements){
        elements.className = this.className;
        const messageToPost = {[this.call1] : this.addCode, [this.call2] : this.apiId, [this.call3] : elements};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    updateUIElement(elements){
        const messageToPost = {[this.call1] : this.updateCode, [this.call2] : this.apiId, [this.call3] : elements};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    deleteUIElement(elements){
        var args = Array.prototype.slice.call(arguments);
        const messageToPost = {[this.call1] : this.deleteCode, [this.call2] : this.apiId, [this.call3] : args};
        window.webkit.messageHandlers.callbackHandler.postMessage(messageToPost);
    }
    
    destroy(className) {
        window[className] = null;
        delete window[className]
    }
};
