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
    
    let renderMethod : String
    
    let factory = UIFactory();
    
    let responseParser = ResponseParser();
    
    let randomRange: UInt32 = 100000
    
    override init(){
        renderMethod = "render"
        scriptMessageHandler = "callbackHandler"
        jsapi = "JSAPI"
        jsCommunicator = "JS_COMMUNICATOR"
    }
    
    init(handlerName: String, apiFileName: String, scriptCommunicatorName:String){
        scriptMessageHandler = handlerName
        jsapi = apiFileName
        jsCommunicator = scriptCommunicatorName
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
        let init2 = "var " + jsCommunicator + "= new JSAPI('" + String(apiId) + "');";
        let init3 = content;
        var init4 = "";
        for script in scriptNames{
            init4 += jsCommunicator + ".registerObject('" + script + "');";
        }
        do {
            try _ = webView.evaluateJavaScript(init1 + ";" + init2 + ";" + init3 + ";" + init4 ){ (result, error) in
                print("ok");

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
            try _ = webView.evaluateJavaScript("var " + jsCommunicator + "= new JSAPI('" + String(apiId) + "');"){ (result, error) in
                print("ok");
                
            }*/
        } catch {
            print("JS API init error!")
            completionHandler(-1);
        }
        
        // registers the script content in sandbox and class names in JSAPI
        do {
            /*try _ = webView.evaluateJavaScript(content){ (result, error) in
                print("ok");
                
            }
            
            for script in scriptNames{
                try _ = webView.evaluateJavaScript(jsCommunicator + ".registerObject('" + script + "')"){ (result, error) in
                    print("ok");
                    
                }
            }*/
        }
        catch {
            print("registerObject failed! probably not an object")
        }
        


    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i += 1){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    
    // executes the script which is saved inside webView
    func executeScript(sandboxId : Int, scriptId: Int) -> String {
        var resultString : String = "";
        if (webViews.count > sandboxId && webViews[sandboxId].configuration.userContentController.userScripts.count > scriptId){

            resultString = execute(sandboxId, functionName: webViews[sandboxId].configuration.userContentController.userScripts[scriptId].source, functionParams: [])
            
        }
        return resultString;
    }
    
    // executes the script content inside sandbox
    func executeContent(sandboxId: Int, content : String){
        if (webViews.count > sandboxId){

            execute(sandboxId, functionName: content, functionParams: [])
        }
    }
    
    // executes the script of specified method of specified class with parameters
    func executeClassContent(sandboxId: Int, className: String, functionName: String, functionParams : [String]){
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
        //print("ID: " + String(diceRoll))

        let scriptQuery = jsCommunicator + ".evaluateClass(" + String(diceRoll) + ", '" + className + "', '" + renderMethod + "')"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                print("ERROR")
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
    
    private func executeClass(sandboxId: Int, className:String, functionName: String, functionParams: [String]) ->NSDictionary {
        var executeClassResult : NSDictionary = NSDictionary()
        
        let diceRoll = Int(arc4random_uniform(randomRange) + 1)
        sync(results){
            self.results[sandboxId][diceRoll] = "init";
        }
        //print(diceRoll)
        
        
        var scriptQuery = jsCommunicator + ".evaluateClass(" + String(diceRoll) + ", '" + className + "', '" + functionName + "'";
        for param in functionParams{
            scriptQuery += ", '" + param + "'";
        }
        scriptQuery += ")"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                print("ERROR")
            }
            
            //print(self.results[sandboxId][diceRoll]!)
            
            if let _ = self.results[sandboxId][diceRoll]! as? NSDictionary{
                executeClassResult = self.results[sandboxId][diceRoll]! as! NSDictionary
            }
            else{
                if let resultString = self.results[sandboxId][diceRoll]! as? String{
                    executeClassResult = [0: resultString]
                }
                else{
                    print("error while reading result executeClass!")
                }
            }
            
            // remove after using
            self.sync(self.results){
                self.results[sandboxId].removeValueForKey(diceRoll)
            }
            // TODO maybe parsing specific results
            
        }
        return executeClassResult;
    }
    
    private func execute(sandboxId: Int, functionName: String, functionParams: [String]) -> String{
        var executeResult : String = "";
        
        let diceRoll = Int(arc4random_uniform(randomRange) + 1)
        sync(results){
            self.results[sandboxId][diceRoll] = "init";
        }
        //print(diceRoll)
        
        
        var scriptQuery = jsCommunicator + ".evaluate(" + String(diceRoll) + ", '" + functionName + "'";
        for param in functionParams{
            scriptQuery += ", '" + param + "'";
        }
        scriptQuery += ")"
        
        // for test
        //scriptQuery = jsCommunicator + ".evaluate(" + String(diceRoll) + ",'test','ppp','qqq')"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                print("ERROR")
            }
            
            //print(self.results[diceRoll]!)

            if let _ :String = self.results[sandboxId][diceRoll]! as? String{
                executeResult = self.results[sandboxId][diceRoll]! as! String
            }
            else{
                print("error while reading result execute!")
            }
            
            // remove after using
            self.sync(self.results){
                self.results[sandboxId].removeValueForKey(diceRoll)
            }
            
            
        }
        return executeResult;
    }
    
    func getWebConfig(messageHandlerName: String, scriptNames : [String]) -> WKWebViewConfiguration{
        
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
    
    func injectScript(scriptName : String, userController : WKUserContentController){
        // Get script that's to be injected into the document
        let js:String = getScriptFileContent(scriptName)
        
        // Specify when and where and what user script needs to be injected into the web document
        let userScript:WKUserScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
        
        // Add the user script to the WKUserContentController instance
        userController.addUserScript(userScript);
    }
    
    // gets the content from file
    func getScriptFileContent(scriptName : String) ->String{
        
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
                // parser TODO
                
                viewCtrl?.executeAS(self.apiConnector[apiId]! , uiElementId: 1, content: "test")
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
    func sync(lock: AnyObject, closure: () -> Void) {
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
    }

}
