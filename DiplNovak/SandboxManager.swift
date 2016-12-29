//
//  SandboxManager.swift
//  DiplNovak
//
//  Created by Novak Matus on 08/05/2016.
//

import Foundation
import WebKit

protocol DiplSandboxDelegate: class {
    func debugInfo(_ sandboxId: Int, content: String, severity: Int)
    func addUIElement(_ sandboxId : Int, content : [UIClass])
    func updateUIElement(_ sandboxId : Int, content : [Int: [String: AnyObject]])
    func removeUIElement(_ sandboxId : Int, uiElementId: [Int])
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
   
    func createSandbox(_ view: UIView, scriptNames: [String], content: String, completionHandler : @escaping (Int) -> Void){
        
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
                    self.handleError(-1, error: error! as NSError)
                }
            }
            
            self.sync(self.webViews as AnyObject){
                self.webViews.append(webView)
                self.sandboxId = self.webViews.count
                self.apiConnector[apiId as String] = self.sandboxId - 1;
            }
            self.results.append([Int: AnyObject]());
            completionHandler(self.sandboxId - 1);
            
        }
    }
    
    func initFromUrl (_ sandboxId: Int, urlContent : String, completionHandler : @escaping ([String]) -> Void){
        var urlResult = [String]();
        
        sync(results as AnyObject){
            self.results[sandboxId][self.initActionCode] = "init" as AnyObject?;
        }
        
        webViews[sandboxId].evaluateJavaScript(urlContent) { (result, error) in
            if error != nil {
                let errorMsg = error!.localizedDescription
                if (errorMsg != "JavaScript execution returned a result of an unsupported type"){
                    self.handleError(sandboxId, error: error! as NSError)
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
            self.sync(self.results as AnyObject){
                self.results[sandboxId].removeValue(forKey: self.initActionCode)
            }

            completionHandler(urlResult)
        }

    }
    
    // executes the script which is saved inside webView
    func executeScript(_ sandboxId : Int, scriptId: Int) {
        if (webViews.count > sandboxId && webViews[sandboxId].configuration.userContentController.userScripts.count > scriptId){

            execute(sandboxId, functionName: webViews[sandboxId].configuration.userContentController.userScripts[scriptId].source, functionParams: [])
        }
    }
    
    // executes the script content inside sandbox
    func executeContent(_ sandboxId: Int, content : String){
        if (webViews.count > sandboxId){

            execute(sandboxId, functionName: content, functionParams: [])
        }
    }
    
    // executes the script of specified function of specified class with parameters
    func executeClassContent(_ sandboxId: Int, className: String, functionName: String, functionParams : [AnyObject]){
        if (webViews.count > sandboxId){
            executeClass(sandboxId, className: className, functionName: functionName, functionParams: functionParams)
        }
    }
    
    // executes the render method of specified class
    func executeRender(_ sandboxId: Int, className:String, completionHandler : @escaping (( [UIClass])) -> Void) {
        var resultUI = [UIClass]()
        var renderResult : NSDictionary = NSDictionary()
        
        let diceRoll = Int(arc4random_uniform(randomRange) + 1)
        sync(results as AnyObject){
            self.results[sandboxId][diceRoll] = "init" as AnyObject?;
        }
        let scriptQuery = jsCommunicator + "." + evaluateClassMethod + "(" + String(diceRoll) + ", '" + className + "', '" + renderMethod + "')"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                let errorMsg = error!.localizedDescription
                if (errorMsg != "JavaScript execution returned a result of an unsupported type"){
                    self.handleError(sandboxId, error: error! as NSError)
                    return;
                }
            }
            
            if let _ = self.results[sandboxId][diceRoll]! as? NSDictionary{
                renderResult = self.results[sandboxId][diceRoll]! as! NSDictionary
            }
            else{
                print("error while reading result render!")
            }
            
            // remove after using
            self.sync(self.results as AnyObject){
                self.results[sandboxId].removeValue(forKey: diceRoll)
            }
            
            resultUI = self.responseParser.parseRenderResponse(sandboxId: sandboxId, className: className, renderResult: renderResult)
 
            completionHandler(resultUI)
        }
    }
    
    // execute the function of specified class with parameters
    fileprivate func executeClass(_ sandboxId: Int, className:String, functionName: String, functionParams: [AnyObject]) {
        
        var scriptQuery = jsCommunicator + "." + evaluateClassMethod + "(" + String(-1) + ", '" + className + "', '" + functionName + "'";
        for param in functionParams{

            // check if object or primitive param
            do {
                if param is NSDictionary || param is String{
                    //let test : String = param
                    if let data = param.description.data(using: .utf8) {
                        
                        // With value as AnyObject
                        if (try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]) != nil {
                            scriptQuery += ", " + param.description + "";
                        }
                    }
                }
                else {
                    scriptQuery += ", " + String(describing: param);
                }
                // parsing error => its string, converting to string
            } catch let error {

                // compilator issue, has to be this way
                let errors :NSError = (error as NSError)
                    
                if let e : String = errors.userInfo["NSDebugDescription"]! as? String{
                    if (e == "JSON text did not start with array or object and option to allow fragments not set."){
                        
                        scriptQuery += ", '" + String(describing: param) + "'";
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
                    self.handleError(sandboxId, error: error! as NSError)
                    return;
                }
            }
        }
    }
    
    // execute the function
    fileprivate func execute(_ sandboxId: Int, functionName: String, functionParams: [String]) {
        
        var scriptQuery = jsCommunicator + ".evaluate(" + String(-1) + ", '" + functionName + "'";
        for param in functionParams{
            scriptQuery += ", '" + param + "'";
        }
        scriptQuery += ")"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                let errorMsg = error!.localizedDescription
                if (errorMsg != "JavaScript execution returned a result of an unsupported type"){
                    self.handleError(sandboxId, error: error! as NSError)
                    return;
                }
            }
            
        }
    }
    
    fileprivate func getWebConfig(_ messageHandlerName: String, scriptNames : [String]) -> WKWebViewConfiguration{
        
        // Create WKWebViewConfiguration instance
        let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
        
        // Setup WKUserContentController instance for injecting user script
        let userController:WKUserContentController = WKUserContentController()
        
        // Add a script message handler for receiving  "buttonClicked" event notifications posted from the JS document using window.webkit.messageHandlers.buttonClicked.postMessage script message
        // same scripts within one webview but separate messageHandlers will still be seeing each other
        userController.add(self, name: messageHandlerName)
        
        //inject the scripts
        for script in scriptNames{
            injectScript(script, userController: userController);
        }
        
        // Configure the WKWebViewConfiguration instance with the WKUserContentController
        webCfg.userContentController = userController;
        
        return webCfg;
    }
    
    fileprivate func injectScript(_ scriptName : String, userController : WKUserContentController){
        // Get script that's to be injected into the document
        let js:String = getScriptFileContent(scriptName)
        
        // Specify when and where and what user script needs to be injected into the web document
        let userScript:WKUserScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
        
        // Add the user script to the WKUserContentController instance
        userController.addUserScript(userScript);
    }
    
    // gets the content from file
    fileprivate func getScriptFileContent(_ scriptName : String) ->String{
        
        var script:String?
        
        if let filePath:String = Bundle(for: DiplViewController.self).path(forResource: scriptName, ofType:"js") {
            
            script = try? String (contentsOfFile: filePath, encoding: String.Encoding.utf8)
        }
        return script!;
        
    }
    
    // WKScriptMessageHandler Delegate
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let messageBody:NSDictionary = message.body as? NSDictionary {
            
            // callback handler name
            if (message.name != scriptMessageHandler){
                return;
            }
            
            if let actionID:Int = messageBody[jsApiCallNames[0]] as? Int {
                if let apiId:String = messageBody[jsApiCallNames[1]] as? String{
                    let msg:AnyObject;
                    
                    //async call
                    if (actionID < 0){
                        
                        switch(actionID){
                        case asyncCode :
                            if let msg : [AnyObject] = messageBody[jsApiCallNames[2]] as? [AnyObject] {
                                print(msg);
                                viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: msg.description, severity: 0)
                            }
                            else{
                                viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "asyncCodeFailed", severity: 1)
                            }
                        case initActionCode :
                            if let msg : String = messageBody[jsApiCallNames[2]] as? String {
                                
                                let fullNameArr = msg.components(separatedBy: ",")
                                
                                var nameResult = [String]();
                                for (name) in fullNameArr {
                                    nameResult.append(name);
                                }
                                
                                sync(results as AnyObject){
                                    self.results[self.apiConnector[apiId]!][self.initActionCode] = nameResult as AnyObject?;
                                }
                            }
                            else{
                                viewCtrl?.debugInfo(self.apiConnector[apiId]!, content: "initActionCodeFailed", severity: 2)
                            }
                        case addActionCode :
                            if let msg : NSDictionary = messageBody[jsApiCallNames[2]] as? NSDictionary {
                                let response = self.responseParser.parseRenderResponse(sandboxId: self.apiConnector[apiId]!, className: "", renderResult: msg)
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
                                if (response.count > 0) {
                                    viewCtrl?.updateUIElement(self.apiConnector[apiId]!,content: response)
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
                            msg = messageBody[jsApiCallNames[2]] as! String as AnyObject
                        }
                        else {
                            if let _ = messageBody[jsApiCallNames[2]] as? NSDictionary {
                                msg = messageBody[jsApiCallNames[2]] as! NSDictionary
                            }
                            else{
                                return
                            }
                        }
                        sync(results as AnyObject){
                            self.results[self.apiConnector[apiId]!][actionID] = msg;
                        }
                    }
                }
                else{
                    viewCtrl?.debugInfo(-1, content: "Failure! Wrong apiId.", severity: 2)
                }
            }
            else{
                viewCtrl?.debugInfo(-1, content: "Failure! Wrong actionId.", severity: 2)
                
            }
        }
    }
    
    fileprivate func handleError(_ sandboxId : Int, error : NSError){
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
        if let exceptionMsg = error.userInfo["WKJavaScriptExceptionSourceURL"]! as? URL{
            if (exceptionMsg.debugDescription != "about:blank"){
                errorReport += "At location: " + exceptionMsg.debugDescription
            }
        }
        self.viewCtrl!.debugInfo(sandboxId, content: errorReport, severity: 2);
    }
    
    fileprivate func randomStringWithLength (_ len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (_) in 0 ..< len{
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    // function for thread-safe object synchronizing
    fileprivate func sync(_ lock: AnyObject, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func destroySandbox(_ sandboxId : Int) -> Bool{
        sync(webViews as AnyObject){
            self.webViews.remove(at: sandboxId)
        }
        return true
    }
    
    deinit {
        webViews.removeAll(keepingCapacity: false)
        results.removeAll(keepingCapacity: false)
        apiConnector.removeAll(keepingCapacity: false)
    }

}
