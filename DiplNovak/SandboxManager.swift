//
//  SandboxManager.swift
//  DiplNovak
//
//  Created by Novak Second on 08/05/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import Foundation
import WebKit

class SandboxManager : NSObject, WKScriptMessageHandler{
    
    var webViews = [WKWebView]()
    
    var results = [Int: AnyObject]();
    
    var sandboxId: Int = 0
    
    let scriptMessageHandler: String;
    
    let jsapi: String
    
    let jsCommunicator: String
    
    let renderMethod : String
    
    let factory = UIFactory();
    
    let randomRange: UInt32 = 100000
    
    static var minions:[UIView] = [] {
        didSet {
            
        }
    }
    
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
   
    func createSandbox(view: UIView, scripts: [String]) -> Int{
        //Set up WKWebView configuration
        let webConfiguration = getWebConfig(scriptMessageHandler, scriptNames: scripts)
        
        // Create a WKWebView instance
        let webView = WKWebView (frame: view.frame, configuration: webConfiguration)
        
        let jsApiInit:String = getScriptFileContent(jsapi)
        
        do {
            try _ = webView.evaluateJavaScript(jsApiInit)
            try _ = webView.evaluateJavaScript("var " + jsCommunicator + "= new JSAPI();")
        } catch {
            print("JS API init error!")
            return -1
        }
        
        for script in scripts{
            let js = getScriptFileContent(script)
            do {
                try _ = webView.evaluateJavaScript(js)
                
                try _ = webView.evaluateJavaScript(jsCommunicator + ".registerObject('" + script + "')")
            }
            catch {
                print("registerObject failed! probably not an object")
            }
            
        }
        /*do {
            // not executing TODO
            //try _ = webView.evaluateJavaScript(jsCommunicator + ".init('JS2')")
            //try _ = webView.evaluateJavaScript(jsCommunicator + ".render('testClass')")
            //try _ = webView.evaluateJavaScript(jsCommunicator + ".destroy('testClass')")
            //try _ = webView.evaluateJavaScript(jsCommunicator + ".init('testClass')")
            
        }
        catch{
            
        }*/

            

        
        sync(webViews){
            self.webViews.append(webView)
            self.sandboxId = self.webViews.count
        }
        
        return sandboxId - 1;
    }
    
    func destroySandbox(sandboxId : Int) -> Bool{
        sync(webViews){
            self.webViews.removeAtIndex(sandboxId)
        }
        return true
    }
    
    func executeScript(sandboxId : Int, scriptId: Int) -> String {
        var resultString : String = "";
        if (webViews.count > sandboxId && webViews[sandboxId].configuration.userContentController.userScripts.count > scriptId){

            resultString = execute(sandboxId, functionName: webViews[sandboxId].configuration.userContentController.userScripts[scriptId].source, functionParams: [])
            
        }
        return resultString;
    }
    
    func executeContent(sandboxId: Int, content : String) -> String{
        var resultString : String = "";
        if (webViews.count > sandboxId){

            resultString = execute(sandboxId, functionName: content, functionParams: [])
            
        }
        return resultString;
    }
    
    func executeClassContent(sandboxId: Int, className: String, functionName: String, functionParams : [String]) -> NSDictionary{
        var resultString : NSDictionary = NSDictionary();
        if (webViews.count > sandboxId){
            
            resultString = executeClass(sandboxId, className: className, functionName: functionName, functionParams: functionParams)
            
        }
        return resultString;
    }
    
    func test(completionHandler : ((javaScriptString: String, javaScriptString2: String, isResponse : Bool) -> Void)) {
        
    }
    
    func executeRender(sandboxId: Int, className:String, completionHandler : ((objects : [UIClass]) -> Void)) {
        var resultUI = [UIClass]()
        var renderResult : NSDictionary = NSDictionary()
        
        let diceRoll = Int(arc4random_uniform(randomRange) + 1)
        sync(results){
            self.results[diceRoll] = "init";
        }
        print(diceRoll)

        let scriptQuery = jsCommunicator + ".evaluateClass(" + String(diceRoll) + ", '" + className + "', '" + renderMethod + "')"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                print("ERROR")
            }
            
            print(self.results[diceRoll]!)
            

            
            if let _ = self.results[diceRoll]! as? NSDictionary{
                renderResult = self.results[diceRoll]! as! NSDictionary
            }
            else{
                print("error while reading result render!")
            }
            
            // remove after using
            self.sync(self.results){
                self.results.removeValueForKey(diceRoll)
            }
            
            resultUI = self.parseRender(sandboxId, className: className, renderResult: renderResult);
            
            completionHandler(objects: resultUI)
        }
    }
    
    private func executeClass(sandboxId: Int, className:String, functionName: String, functionParams: [String]) ->NSDictionary {
        var parseResult : NSDictionary = NSDictionary()
        
        let diceRoll = Int(arc4random_uniform(randomRange) + 1)
        sync(results){
            self.results[diceRoll] = "init";
        }
        print(diceRoll)
        
        
        var scriptQuery = jsCommunicator + ".evaluateClass(" + String(diceRoll) + ", '" + className + "', '" + functionName + "'";
        for param in functionParams{
            scriptQuery += ", '" + param + "'";
        }
        scriptQuery += ")"
        
        //test
        //scriptQuery = jsCommunicator + ".evaluateClass(" + String(diceRoll) + ", 'JS2', 'render')"
        
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                print("ERROR")
            }
            
            print(self.results[diceRoll]!)
            
            if let _ = self.results[diceRoll]! as? NSDictionary{
                parseResult = self.results[diceRoll]! as! NSDictionary
            }
            else{
                if let resultString = self.results[diceRoll]! as? String{
                    parseResult = [0: resultString]
                }
                else{
                    print("error while reading result executeClass!")
                }
            }
            
            // remove after using
            self.sync(self.results){
                self.results.removeValueForKey(diceRoll)
            }
            // TODO netreba asi
            //self.parseResult(parseResult);
            
            
        }
        return parseResult;
        
        // for test
        /*JSON
        let json = "{'act':'invoke','target':'test','args':['test']}";
        scriptQuery = jsCommunicator + ".evaluateClass(" + json + ")"*/
    }
    
    private func parseRender(sandboxId: Int, className: String, renderResult: NSDictionary) -> [UIClass]{
        // render response
        var result  = [UIClass]()
        
        if let itemsArray : NSArray = renderResult.objectForKey("uiElements") as? NSArray{
            
            for (item) in itemsArray {
                if let content: NSDictionary = item.objectForKey("button") as? NSDictionary {
                    
                    if let title : String = content.objectForKey("title") as? String{
                        let cgRect = CGRect(x: 100, y: 100, width: 100, height: 50)
                        var cgRect2 = CGRect(x: 100, y: 100, width: 100, height: 50)
                        if (title == "button2"){
                            cgRect2 = CGRect(x: 100, y: 200, width: 100, height: 50)
                        }
                        
                        if let uiButton :UIButton = factory.createButton(cgRect, cgRect2: cgRect2, color: UIColor.greenColor(), title : title, state: UIControlState.Normal){
                            var functionName = ""
                            var params = [String]()
                            
                            if let fn : String = content.objectForKey("onClick") as? String {
                                functionName = fn;
                                if let paramsArray : NSArray = content.objectForKey("params") as? NSArray{
                                    for (paramOjb) in paramsArray{
                                        if let paramDictionary : String = paramOjb.objectForKey("value") as? String{
                                            params.append(paramDictionary)
                                        }
                                    }
                                }
                            }
                            
                            if let uiClass : UIClass = UIClass(sandboxId: sandboxId, className: className, functionName: functionName, params: params, uiElement: uiButton){
                                
                                result.append(uiClass)
                            }
                        }
                        
                        
                        
                        
                        continue
                    }
                    
                }
                if let content: NSDictionary = item.objectForKey("label") as? NSDictionary {
                    if let text : String = content.objectForKey("text") as? String{
                        
                        let cgRectLabel = CGRect(x: 50, y: 50, width: 200, height: 21)
                        let uiLabel = factory.createLabel(cgRectLabel, textColor : UIColor.blackColor(), backgroundColor : UIColor.whiteColor(), textAlignment: NSTextAlignment.Center, text: text)
                        
                        if let uiClass : UIClass = UIClass(sandboxId: sandboxId, className: className, functionName: "", params: [], uiElement: uiLabel) {
                            result.append(uiClass)
                        }
                        
                        continue
                    }
                }
                if let content: NSDictionary = item.objectForKey("textfield") as? NSDictionary {
                    if let text : String = content.objectForKey("text") as? String{
                        
                        let cgRectTextField = CGRect(x: 50, y: 70, width: 200, height: 30)
                        let uiTextField = factory.createTextField(cgRectTextField, text: text, backgroundColor : UIColor.blackColor())
                        
                        if let uiClass : UIClass = UIClass(sandboxId: sandboxId, className: className, functionName: "", params: [], uiElement: uiTextField){
                            result.append(uiClass)
                        }
                        
                        continue
                    }
                }
            }
        }
        
        return result
    }
    
    private func parseResult(executeResult : NSDictionary){

    }
    
    private func execute(sandboxId: Int, functionName: String, functionParams: [String]) -> String{
        let executeResult : String = "";
        
        let diceRoll = Int(arc4random_uniform(randomRange) + 1)
        sync(results){
            self.results[diceRoll] = "init";
        }
        print(diceRoll)
        
        
        var scriptQuery = jsCommunicator + ".evaluate(" + String(diceRoll) + ", '" + functionName + "'";
        for param in functionParams{
            scriptQuery += ", '" + param + "'";
        }
        scriptQuery += ")"
        
        // for test
        scriptQuery = jsCommunicator + ".evaluate(" + String(diceRoll) + ",'test','ppp','qqq')"
        
        webViews[sandboxId].evaluateJavaScript(scriptQuery) { (result, error) in
            if error != nil {
                print("ERROR")
            }
            
            print(self.results[diceRoll]!)

            if let _ :String = self.results[diceRoll]! as? String{
                
            }
            else{
                print("error while reading result execute!")
            }
            
            // remove after using
            self.sync(self.results){
                self.results.removeValueForKey(diceRoll)
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
    
    // Button Click Script to Add to Document
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
            let idOfTappedButton:Int = messageBody["ID"] as! Int
            
            let msg:AnyObject;
            
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
            
            
            //print("button tapped: " + String(idOfTappedButton))
            //print("messsage: " + String(msg))
            
            sync(results){
                self.results[idOfTappedButton] = msg;
            }
        }
        
    }
    
    // function for thread-safe object synchronizing
    func sync(lock: AnyObject, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    deinit {
        webViews.removeAll(keepCapacity: false)
        results.removeAll(keepCapacity: false)
    }

}