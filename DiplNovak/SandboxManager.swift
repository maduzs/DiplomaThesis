//
//  SandboxManager.swift
//  DiplNovak
//
//  Created by Novak Second on 08/05/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import Foundation
import WebKit

protocol DiplSandboxDelegate: class {
    func executeAS(sandboxId : Int, uiElementId: Int, content : String)
    func debugInfo(sandboxId: Int, content: String)
    //func addUI(sandboxId : Int, uiElementId: Int, content : String)
    //func updateUI(sandboxId : Int, uiElementId: Int, content : String)
    //func deleteUI(sandboxId : Int, uiElementId: Int, content : String)
}

class SandboxManager : NSObject, WKScriptMessageHandler{
    
    weak var viewCtrl: DiplSandboxDelegate?
 
    var webViews = [WKWebView]()
    
    var results = [[Int: AnyObject]()];
    
    var apiConnector = [String: Int]();
    
    var sandboxId: Int = 0
    
    let scriptMessageHandler: String;
    
    let jsapi: String
    
    let jsCommunicator: String
    
    let evaluateClassMethod : String
    
    let renderMethod : String
    
    let factory = UIFactory();
    
    let responseParser = ResponseParser();
    
    let randomRange: UInt32 = 100000
    
    let initActionCode = -4648;
    
    override init(){
        scriptMessageHandler = "callbackHandler"
        jsapi = "JSAPI"
        jsCommunicator = "JS_COMMUNICATOR"
        evaluateClassMethod = "evaluateClass"
        renderMethod = "render"
    }
    
    init(handlerName: String, apiFileName: String, scriptCommunicatorName:String){
        scriptMessageHandler = handlerName
        jsapi = apiFileName
        jsCommunicator = scriptCommunicatorName
        evaluateClassMethod = "evaluateClass"
        renderMethod = "render"
    }
   
    func createSandbox(view: UIView, scriptNames: [String], content: String, completionHandler : (Int) -> Void){
        
        //Set up WKWebView configuration
        let webConfiguration = getWebConfig(scriptMessageHandler, scriptNames: scriptNames)
        
        // Create a WKWebView instance
        let webView = WKWebView (frame: view.frame, configuration: webConfiguration)
        
        let jsApiInit:String = getScriptFileContent(jsapi)
        
        let apiId = randomStringWithLength(32)

        let init1 = jsApiInit;
        let init2 = "var " + jsCommunicator + " = new JSAPI('" + String(apiId) + "' ," + String(self.initActionCode) + ");";

        webView.evaluateJavaScript(init1 + ";" + init2 +  ";"  ){ (result, error) in
            
            if (error != nil){
                let errorMsg = error!.localizedDescription
                if (errorMsg != "JavaScript execution returned a result of an unsupported type"){
                    self.handleError(-1, error: error!)
                }
            }
            
            self.sync(self.webViews){
                self.webViews.append(webView)
                self.sandboxId = self.webViews.count
                self.apiConnector[apiId as String] = self.sandboxId - 1;
            }
            self.results.append([Int: AnyObject]());
            completionHandler(self.sandboxId - 1);
            
        }
        /*try _ = webView.evaluateJavaScript(jsApiInit){ (result, error) in
         print("ok");
         
         }
         */

    }
    
    func initFromUrl (sandboxId: Int, urlContent : String, completionHandler : ([String]) -> Void){
        var urlResult = [];
        
        sync(results){
            self.results[sandboxId][self.initActionCode] = "init";
        }
        
        // TODO delete
        //var contentFile = getScriptFileContent("JS");
        //contentFile += getScriptFileContent("JS2");
        
        webViews[sandboxId].evaluateJavaScript(urlContent) { (result, error) in
            if error != nil {
                let errorMsg = error!.localizedDescription
                if (errorMsg != "JavaScript execution returned a result of an unsupported type"){
                    self.handleError(sandboxId, error: error!)
                    return;
                }
            }
            
            if let _ = self.results[sandboxId][self.initActionCode]! as? [String]{
                urlResult = self.results[sandboxId][self.initActionCode]! as! [String]
            }
            else{
                print("error while reading result render!")
            }
 
            // remove after using
            self.sync(self.results){
                self.results[sandboxId].removeValueForKey(self.initActionCode)
            }

            completionHandler(urlResult as! [String])
        }

    }
    
    private func handleError(sandboxId : Int, error : NSError){
        var errorReport = "ERROR: "
        if let exceptionMsg = error.userInfo["NSLocalizedDescription"]! as? String{
            errorReport += exceptionMsg + "\r\n"
        }
        if let exceptionMsg = error.userInfo["WKJavaScriptExceptionMessage"]! as? String{
            errorReport += exceptionMsg + "\r\n"
        }
        if let exceptionMsg = error.userInfo["WKJavaScriptExceptionLineNumber"]! as? Int{
            errorReport += "At line: " + String(exceptionMsg)
        }
        if let exceptionMsg = error.userInfo["WKJavaScriptExceptionColumnNumber"]! as? Int{
            errorReport += " , Column: " + String(exceptionMsg) + "\r\n"
        }
        if let exceptionMsg = error.userInfo["WKJavaScriptExceptionSourceURL"]! as? NSURL{
            if (exceptionMsg.debugDescription != "about:blank"){
                errorReport += "At location: " + exceptionMsg.debugDescription
            }
        }
        self.viewCtrl!.debugInfo(sandboxId, content: errorReport);
    }
    
    private func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (_) in 0 ..< len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    // executes the script which is saved inside webView
    func executeScript(sandboxId : Int, scriptId: Int) {
        if (webViews.count > sandboxId && webViews[sandboxId].configuration.userContentController.userScripts.count > scriptId){

            execute(sandboxId, functionName: webViews[sandboxId].configuration.userContentController.userScripts[scriptId].source, functionParams: [])
            
        }
    }
    
    // executes the script content inside sandbox
    func executeContent(sandboxId: Int, content : String){
        if (webViews.count > sandboxId){

            execute(sandboxId, functionName: content, functionParams: [])
        }
    }
    
    // executes the script of specified function of specified class with parameters
    func executeClassContent(sandboxId: Int, className: String, functionName: String, functionParams : [AnyObject]){
        if (webViews.count > sandboxId){
            
            executeClass(sandboxId, className: className, functionName: functionName, functionParams: functionParams)
        }
    }
    
    // executes the render method of specified class
    func executeRender(sandboxId: Int, className:String, completionHandler : (( [UIClass])) -> Void) {
        var resultUI = [UIClass]()
        var renderResult : NSDictionary = NSDictionary()
        
        let diceRoll = Int(arc4random_uniform(randomRange) + 1)
        sync(results){
            self.results[sandboxId][diceRoll] = "init";
        }
        let scriptQuery = jsCommunicator + "." + evaluateClassMethod + "(" + String(diceRoll) + ", '" + className + "', '" + renderMethod + "')"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                let errorMsg = error!.localizedDescription
                if (errorMsg != "JavaScript execution returned a result of an unsupported type"){
                    self.handleError(sandboxId, error: error!)
                    return;
                }
            }
            
            //print(self.results[sandboxId][diceRoll]!)
            
            if let _ = self.results[sandboxId][diceRoll]! as? NSDictionary{
                renderResult = self.results[sandboxId][diceRoll]! as! NSDictionary
            }
            else{
                print("error while reading result render!")
            }
            
            // remove after using
            self.sync(self.results){
                self.results[sandboxId].removeValueForKey(diceRoll)
            }
            
            resultUI = self.responseParser.parseRenderResponse(sandboxId, className: className, renderResult: renderResult)
 
            completionHandler(resultUI)
        }
    }
    
    // execute the function of specified class with parameters
    private func executeClass(sandboxId: Int, className:String, functionName: String, functionParams: [AnyObject]) {
        
        var scriptQuery = jsCommunicator + "." + evaluateClassMethod + "(" + String(-1) + ", '" + className + "', '" + functionName + "'";
        for param in functionParams{
            scriptQuery += ", '" + String(param) + "'";
        }
        scriptQuery += ")"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                let errorMsg = error!.localizedDescription
                if (errorMsg != "JavaScript execution returned a result of an unsupported type"){
                    self.handleError(sandboxId, error: error!)
                    return;
                }
            }
        }
    }
    
    // execute the function
    private func execute(sandboxId: Int, functionName: String, functionParams: [String]) {
        
        var scriptQuery = jsCommunicator + ".evaluate(" + String(-1) + ", '" + functionName + "'";
        for param in functionParams{
            scriptQuery += ", '" + param + "'";
        }
        scriptQuery += ")"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                let errorMsg = error!.localizedDescription
                if (errorMsg != "JavaScript execution returned a result of an unsupported type"){
                    self.handleError(sandboxId, error: error!)
                    return;
                }
            }
            
        }
    }
    
    private func getWebConfig(messageHandlerName: String, scriptNames : [String]) -> WKWebViewConfiguration{
        
        // Create WKWebViewConfiguration instance
        let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
        
        // Setup WKUserContentController instance for injecting user script
        let userController:WKUserContentController = WKUserContentController()
        
        // Add a script message handler for receiving  "buttonClicked" event notifications posted from the JS document using window.webkit.messageHandlers.buttonClicked.postMessage script message
        // same scripts within one webview but separate messageHandlers will still be seeing each other
        userController.addScriptMessageHandler(self, name: messageHandlerName)
        
        //inject the scripts
        for script in scriptNames{
            injectScript(script, userController: userController);
        }
        
        // Configure the WKWebViewConfiguration instance with the WKUserContentController
        webCfg.userContentController = userController;
        
        return webCfg;
    }
    
    private func injectScript(scriptName : String, userController : WKUserContentController){
        // Get script that's to be injected into the document
        let js:String = getScriptFileContent(scriptName)
        
        // Specify when and where and what user script needs to be injected into the web document
        let userScript:WKUserScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
        
        // Add the user script to the WKUserContentController instance
        userController.addUserScript(userScript);
    }
    
    // gets the content from file
    private func getScriptFileContent(scriptName : String) ->String{
        
        var script:String?
        
        if let filePath:String = NSBundle(forClass: DiplViewController.self).pathForResource(scriptName, ofType:"js") {
            
            script = try? String (contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        }
        return script!;
        
    }
    
    // WKScriptMessageHandler Delegate
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let messageBody:NSDictionary = message.body as? NSDictionary {
            
            // callback handler name
            if (message.name != scriptMessageHandler){
                return;
            }
            let actionID:Int = messageBody["ID"] as! Int
            
            let apiId:String = messageBody["apiId"] as! String
            
            let msg:AnyObject;
            
            //async call
            if (actionID < 0){
                
                switch(actionID){
                case -1 :
                    // parser TODO
                    if let _ = messageBody["msg"] as? String {
                        msg = messageBody["msg"] as! String
                        print(msg);
                        viewCtrl?.executeAS(self.apiConnector[apiId]! , uiElementId: 0, content: String(msg));
                    }
                    else{
                        viewCtrl?.executeAS(self.apiConnector[apiId]! , uiElementId: 0, content: "failed");
                    }
                case initActionCode :
                    if let _ = messageBody["msg"] as? String {
                        msg = messageBody["msg"] as! String
                        
                        let fullNameArr = msg.componentsSeparatedByString(",")
                        
                        var nameResult = [String]();
                        for (name) in fullNameArr {
                            nameResult.append(name);
                        }
                        
                        sync(results){
                            self.results[self.apiConnector[apiId]!][self.initActionCode] = nameResult;
                        }
                    }
                    else {
                        if let _ = messageBody["msg"] as? NSDictionary {
                            msg = messageBody["msg"] as! NSDictionary
                        }
                        else{
                            return
                        }
                    }
                default: return
                }

            }
            // normal call
            else{
                if let _ = messageBody["msg"] as? String {
                    msg = messageBody["msg"] as! String
                }
                else {
                    if let _ = messageBody["msg"] as? NSDictionary {
                        msg = messageBody["msg"] as! NSDictionary
                    }
                    else{
                        return
                    }
                }
                
                print("action ID: " + String(actionID) + " message: " + String(msg))
                
                sync(results){
                    self.results[self.apiConnector[apiId]!][actionID] = msg;
                }
            }
        }
    }
    
    // function for thread-safe object synchronizing
    private func sync(lock: AnyObject, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func destroySandbox(sandboxId : Int) -> Bool{
        sync(webViews){
            self.webViews.removeAtIndex(sandboxId)
        }
        return true
    }
    
    deinit {
        webViews.removeAll(keepCapacity: false)
        results.removeAll(keepCapacity: false)
        apiConnector.removeAll(keepCapacity: false)
    }

}
