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
    func debugInfo(sandboxId: Int, content: String, severity: Int)
    func addUIElement(sandboxId : Int, content : [UIClass])
    func updateUIElement(sandboxId : Int, uiElementId: [Int], content : [[AnyObject]])
    func removeUIElement(sandboxId : Int, uiElementId: [Int])
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
    let asyncCode = -1;
    let addActionCode = -11;
    let updateActionCode = -22;
    let deleteActionCode = -99;
    
    let jsApiCallNames = ["ID", "apiId", "msg"];
    
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

        let jsCodes = [self.initActionCode, self.asyncCode, self.addActionCode, self.updateActionCode, self.deleteActionCode];
        let init1 = jsApiInit;
        let init2 = "var " + jsCommunicator + " = new JSAPI('" + String(apiId) + "' ," + jsApiCallNames.description + "," + jsCodes.description + ");";

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
    }
    
    func initFromUrl (sandboxId: Int, urlContent : String, completionHandler : ([String]) -> Void){
        var urlResult = [];
        
        sync(results){
            self.results[sandboxId][self.initActionCode] = "init";
        }
        
        // TODO delete
        var contentFile = getScriptFileContent("JS");
        contentFile += getScriptFileContent("JS2");
        
        webViews[sandboxId].evaluateJavaScript(contentFile) { (result, error) in
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

            // check if object or primitive param
            do {
                if param is NSDictionary || param is String{
                    if let data = param.dataUsingEncoding(NSUTF8StringEncoding) {
                        
                        // With value as AnyObject
                        if (try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]) != nil {
                            scriptQuery += ", " + param.description + "";
                        }
                    }
                }
                else {
                    scriptQuery += ", " + String(param);
                }
                // parsing error => its string, converting to string
            } catch let error {

                // compilator issue, has to be this way
                let errors :NSError = (error as? NSError!)!
                    
                if let e : String = errors.userInfo["NSDebugDescription"]! as? String{
                    if (e == "JSON text did not start with array or object and option to allow fragments not set."){
                        
                        scriptQuery += ", '" + String(param) + "'";
                    }
                    else{
                        viewCtrl?.debugInfo(sandboxId, content: "parsing parameters failed! " + errors.userInfo.description, severity: 1)
                    }
                }
                
            }
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
            
            // TODO error handle
            let actionID:Int = messageBody[jsApiCallNames[0]] as! Int
            
            let apiId:String = messageBody[jsApiCallNames[1]] as! String
            
            let msg:AnyObject;
            
            //async call
            if (actionID < 0){
                
                switch(actionID){
                case asyncCode :
                    if let msg : [AnyObject] = messageBody[jsApiCallNames[2]] as? [AnyObject] {
                        viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: msg.description, severity: 0)
                    }
                    else{
                        viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "asyncCodeFailed", severity: 1)
                    }
                case initActionCode :
                    if let msg : String = messageBody[jsApiCallNames[2]] as? String {
                        
                        let fullNameArr = msg.componentsSeparatedByString(",")
                        
                        var nameResult = [String]();
                        for (name) in fullNameArr {
                            nameResult.append(name);
                        }
                        
                        sync(results){
                            self.results[self.apiConnector[apiId]!][self.initActionCode] = nameResult;
                        }
                    }
                    else{
                        viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "initActionCodeFailed", severity: 2)
                    }
                case addActionCode :
                    if let msg : NSDictionary = messageBody[jsApiCallNames[2]] as? NSDictionary {
                        print(msg);
                        //parse TODO :)
                        let response = self.responseParser.parseRenderResponse(self.apiConnector[apiId]!, className: "", renderResult: msg)
                        if (response.count > 0) {
                            self.viewCtrl?.addUIElement(self.apiConnector[apiId]!, content: response)
                        }
                        else{
                            self.viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "empty elements from action", severity: 1)
                        }
                    }
                    else{
                        viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "add action failed!", severity: 1)
                    }
                case updateActionCode :
                    if let msg : [AnyObject] = messageBody[jsApiCallNames[2]] as? [AnyObject] {
                        
                        let response = self.responseParser.parseUpdateResponseId(self.apiConnector[apiId]!, content: msg);
                        if (response.0.count > 0 && response.0.count == response.1.count) {
                            viewCtrl?.updateUIElement(self.apiConnector[apiId]!, uiElementId: response.0, content: response.1)
                        }
                        else{
                            viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "nothing to parse!", severity: 0)
                        }
                    }
                    else{
                        viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "update action failed!", severity: 1)
                    }
                case deleteActionCode :
                    if let msg : [AnyObject] = messageBody[jsApiCallNames[2]] as? [AnyObject] {
                        
                        let response = self.responseParser.parseDeleteResponse(msg)
                        
                        if (response.count > 0){
                            viewCtrl?.removeUIElement(self.apiConnector[apiId]!, uiElementId: response)
                        }
                        else{
                            viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "nothing to delete!", severity: 1)
                        }
                    }
                    else{
                        viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "deleteCodeFailed", severity: 1)
                    }

                default: return
                }

            }
            // normal call
            else{
                if let _ = messageBody[jsApiCallNames[2]] as? String {
                    msg = messageBody[jsApiCallNames[2]] as! String
                }
                else {
                    if let _ = messageBody[jsApiCallNames[2]] as? NSDictionary {
                        msg = messageBody[jsApiCallNames[2]] as! NSDictionary
                    }
                    else{
                        return
                    }
                }
                sync(results){
                    self.results[self.apiConnector[apiId]!][actionID] = msg;
                }
            }
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
        self.viewCtrl!.debugInfo(sandboxId, content: errorReport, severity: 2);
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
