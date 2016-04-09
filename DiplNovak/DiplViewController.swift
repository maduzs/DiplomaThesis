//
//  DiplViewController.swift
//  DiplNovak
//
//  Created by Novak Second on 28/02/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import UIKit
import WebKit

class DiplViewController: UIViewController, WKScriptMessageHandler, DiplViewDelegate {
    
    @IBOutlet weak var containerView: JSView! {
        didSet {
            containerView.dataSource = self
        }
    }
    
    var webViews = [WKWebView]()
    
    let scriptMessageHandler = "buttonClicked";

    func executeJS(buttonId : Int, content : String){
        switch (buttonId){
        case 0 :
            executeA(0)
        case 1 :
            executeA(1)
        case 2 :
            executeA(2)
        case 3 :
            executeB(0)
        case 4 :
            executeCustom(content)
        case 5 :
            executeCustomA(content)
        case 6 :
            executeCustomB(content)
        default :
            return
        }
        //containerView.setNeedsDisplay();
    }
    
    //executes the script of webView on specified index
    func executeA(scriptIndex : Int){
        if (webViews.count > 0 && webViews[0].configuration.userContentController.userScripts.count > scriptIndex){
            webViews[0].evaluateJavaScript(webViews[0].configuration.userContentController.userScripts[scriptIndex].source, completionHandler: nil)
        }
    }
    
    //executes the script of webView2 on specified index
    func executeB(scriptIndex : Int){
        if (webViews.count > 1 && webViews[1].configuration.userContentController.userScripts.count > scriptIndex){
            webViews[1].evaluateJavaScript(webViews[1].configuration.userContentController.userScripts[scriptIndex].source, completionHandler: nil)
        }
    }
    
    func executeCustom(content : String){
        // create new WKWebView if it doesnt exist
        if !(webViews.count > 2){
            
            //Set up WKWebView configuration
            let webConfiguration = getWebConfig(scriptMessageHandler, scriptNames: [])
            
            // Create a WKWebView instance
            let webView = WKWebView (frame: self.view.frame, configuration: webConfiguration)
            
            webViews.append(webView)
        }
        else {
            webViews.last!.evaluateJavaScript(content, completionHandler: customComplete)
        }
    }
    
    func executeCustomA(content : String){
        if (webViews.count > 0){
            webViews[0].evaluateJavaScript(content, completionHandler: customComplete)
        }
    }
    
    func executeCustomB(content : String){
        if (webViews.count > 1){
            webViews[1].evaluateJavaScript(content, completionHandler: customComplete)
        }
    }
    
    func customComplete (t: AnyObject?, s: NSError?) -> Void{
        
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
        let js:String = addClickScript(scriptName)
        
        // Specify when and where and what user script needs to be injected into the web document
        let userScript:WKUserScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
        
        // Add the user script to the WKUserContentController instance
        userController.addUserScript(userScript);
    }
    
    // Button Click Script to Add to Document
    func addClickScript(scriptName : String) ->String{
        
        var script:String?
        
        if let filePath:String = NSBundle(forClass: DiplViewController.self).pathForResource(scriptName, ofType:"js") {
            
            script = try? String (contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        }
        return script!;
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up WKWebView configuration
        var scriptNames = [String]()
        scriptNames.append("Click")
        scriptNames.append("Click2")
        scriptNames.append("Click3")
        var webConfiguration = getWebConfig(scriptMessageHandler, scriptNames: scriptNames)
        
        // Create a WKWebView instance
        let webView = WKWebView (frame: self.view.frame, configuration: webConfiguration)
        
        // Delegate to handle navigation of web content
        //webView!.navigationDelegate = self
        
        //Set up WKWebView configuration
        scriptNames = []
        scriptNames.append("Click4")
        webConfiguration = getWebConfig(scriptMessageHandler, scriptNames: scriptNames)
        
        // Create a WKWebView instance
        let webView2 = WKWebView (frame: self.view.frame, configuration: webConfiguration)
        
        // Delegate to handle navigation of web content
        //webView2!.navigationDelegate = self
        
        // prekryje JSView s wkwebview
        //view.addSubview(webView!)
        //self.view = self.webView
        
        //add the webViews to array of webViews
        webViews.append(webView)
        webViews.append(webView2)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard")))

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func dismissKeyboard(){
        containerView.textView1.resignFirstResponder()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // WKScriptMessageHandler Delegate
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let messageBody:NSDictionary = message.body as? NSDictionary {
            let idOfTappedButton:String = messageBody["ID"] as! String
            
            let msg:String = messageBody["msg"] as! String
            
            print("button tapped: " + idOfTappedButton)
            print("messsage: " + String(msg))
            containerView.label1.text = msg;
        }
        
    }
    
    // Helper
    func showAlertWithMessage(message:String) {
        let alertAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
        }
        
        let alertView:UIAlertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertView.addAction(alertAction)
        
        self.presentViewController(alertView, animated: true, completion: { () -> Void in
            
        })
    }
    

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
