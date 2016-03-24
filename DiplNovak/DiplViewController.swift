//
//  DiplViewController.swift
//  DiplNovak
//
//  Created by Novak Second on 28/02/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import UIKit
import WebKit

class DiplViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    @IBOutlet var containerView: JSView!
    
    @IBAction func button(sender: UIButton, forEvent event: UIEvent) {
        executeA()
    }
    
    @IBAction func button2(sender: UIButton, forEvent event: UIEvent) {
        executeB()
    }
    
    
    @IBAction func button3(sender: UIButton, forEvent event: UIEvent) {
        executeC()
    }
    
    
    @IBAction func button4(sender: UIButton, forEvent event: UIEvent) {
        executeD()
    }
    
    
    @IBAction func runButton(sender: UIButton, forEvent event: UIEvent) {
        label1.text = "test";
        executeCustom(textView1.text);
    }
    
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var label1: UILabel!
    
    var webView: WKWebView!
    var webView2: WKWebView!

    
    func executeA(){
        if (webView.configuration.userContentController.userScripts.count > 0){
            webView.evaluateJavaScript(webView.configuration.userContentController.userScripts[0].source, completionHandler: nil)
        }
    }
    
    func executeB(){
        if (webView.configuration.userContentController.userScripts.count > 1){
            webView.evaluateJavaScript(webView.configuration.userContentController.userScripts[1].source, completionHandler: nil)
        }
    }
    
    func executeC(){
        if (webView.configuration.userContentController.userScripts.count > 2){
            webView.evaluateJavaScript(webView.configuration.userContentController.userScripts[2].source, completionHandler: nil)
        }
    }
    
    func executeD(){
        if (webView2.configuration.userContentController.userScripts.count > 0){
            webView2.evaluateJavaScript(webView2.configuration.userContentController.userScripts[0].source, completionHandler: nil)
        }
    }
    
    func executeCustom(command : String){
        
    }
    
    var webConfig:WKWebViewConfiguration {
        get {
            
            // Create WKWebViewConfiguration instance
            let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
            
            // Setup WKUserContentController instance for injecting user script
            let userController:WKUserContentController = WKUserContentController()
            
            // Add a script message handler for receiving  "buttonClicked" event notifications posted from the JS document using window.webkit.messageHandlers.buttonClicked.postMessage script message
            // same scripts within one webview but separate messageHandlers will still be seeing each other
            userController.addScriptMessageHandler(self, name: "buttonClicked")
            
            // Get script that's to be injected into the document
            //let js:String = addButtonScript()
            var js:String = addClickScript("Click")
            
            // Specify when and where and what user script needs to be injected into the web document
            var userScript:WKUserScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
            
            // Add the user script to the WKUserContentController instance
            userController.addUserScript(userScript);
            
            js = addClickScript("Click2")
            userScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
            userController.addUserScript(userScript)
            
            js = addClickScript("Click3")
            userScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
            userController.addUserScript(userScript)
            
            // Configure the WKWebViewConfiguration instance with the WKUserContentController
            webCfg.userContentController = userController;
            
            return webCfg;
        }
    }
    
    var webConfig2:WKWebViewConfiguration {
        get {
            
            // Create WKWebViewConfiguration instance
            let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
            
            // Setup WKUserContentController instance for injecting user script
            let userController:WKUserContentController = WKUserContentController()
            
            // Add a script message handler for receiving  "buttonClicked" event notifications posted from the JS document using window.webkit.messageHandlers.buttonClicked.postMessage script message
            userController.addScriptMessageHandler(self, name: "button2Clicked")
            
            // Get script that's to be injected into the document
            //let js:String = addButtonScript()
            let js:String = addClickScript("Click4")
            
            // Specify when and where and what user script needs to be injected into the web document
            let userScript:WKUserScript =  WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: false)
            
            // Add the user script to the WKUserContentController instance
            userController.addUserScript(userScript)
            
            // Configure the WKWebViewConfiguration instance with the WKUserContentController
            webCfg.userContentController = userController;
            
            return webCfg;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a WKWebView instance
        webView = WKWebView (frame: self.view.frame, configuration: webConfig)
        
        // Delegate to handle navigation of web content
        webView!.navigationDelegate = self
        
        // Create a WKWebView instance
        webView2 = WKWebView (frame: self.view.frame, configuration: webConfig2)
        
        // Delegate to handle navigation of web content
        webView2!.navigationDelegate = self
        
        // prekryje JSView s wkwebview
        //view.addSubview(webView!)
        
        //self.view = self.webView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load the HTML document
        loadHtml()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Button Click Script to Add to Document
    func addButtonScript() ->String{
        // Script: When window is loaded, execute an anonymous function that adds a "click" event handler function to the "ClickMeButton" button element. The "click" event handler calls back into our native code via the window.webkit.messageHandlers.buttonClicked.postMessage call
        var script:String?
        
        if let filePath:String = NSBundle(forClass: DiplViewController.self).pathForResource("ClickMeEventRegister", ofType:"js") {
            
            script = try? String (contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        }
        return script!;
        
    }
    
    func addClickScript(scriptName : String) ->String{
        
        var script:String?
        
        if let filePath:String = NSBundle(forClass: DiplViewController.self).pathForResource(scriptName, ofType:"js") {
            
            script = try? String (contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        }
        return script!;
        
    }
    
    func loadHtml() {
        /*let mainBundle:NSBundle = NSBundle(forClass: DiplViewController.self)

        if let htmlPath = mainBundle.pathForResource("TestFile", ofType: "html") {
            let requestUrl = NSURLRequest(URL: NSURL(fileURLWithPath: htmlPath))
                webView!.loadRequest(requestUrl)
        }
        else {
            showAlertWithMessage("Could not load HTML File!")
        }*/
    }
    
    // WKScriptMessageHandler Delegate
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let messageBody:NSDictionary = message.body as? NSDictionary {
            let idOfTappedButton:String = messageBody["ID"] as! String
            
            let msg:String = messageBody["msg"] as! String
            
            print("button tapped: " + idOfTappedButton)
            print("messsage: " + String(msg))
            label1.text = msg;
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
