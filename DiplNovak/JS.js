var testMethod = function(param, param2) {
    var random = Math.random() * (500);
    
    var now = new Date().getTime();
    while(new Date().getTime() < now + random){ /* do nothing */ }
    
    JS_COMMUNICATOR.sendResponse("test" + param+param2);
    
}





