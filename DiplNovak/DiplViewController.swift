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
    
    var webView: WKWebView!
    var webView2: WKWebView!

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
        default :
            return
        }
        //containerView.setNeedsDisplay();
    }
    
    //executes the script of webView on specified index
    func executeA(scriptIndex : Int){
        if (webView.configuration.userContentController.userScripts.count > scriptIndex){
            webView.evaluateJavaScript(webView.configuration.userContentController.userScripts[scriptIndex].source, completionHandler: nil)
        }
    }
    
    //executes the script of webView2 on specified index
    func executeB(scriptIndex : Int){
        if (webView2.configuration.userContentController.userScripts.count > scriptIndex){
            webView2.evaluateJavaScript(webView2.configuration.userContentController.userScripts[scriptIndex].source, completionHandler: nil)
        }
    }
    
    func executeCustom(content : String){
        webView.evaluateJavaScript(content, completionHandler: customComplete)
    }
    
    func customComplete (t: AnyObject?, s: NSError?) -> Void{
        containerView.label1.text = "cc"
        print("cc")
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
            
            //inject the scripts
            injectScript("Click", userController: userController);
            injectScript("Click2", userController: userController);
            injectScript("Click3", userController: userController);

            // Configure the WKWebViewConfiguration instance with the WKUserContentController
            webCfg.userContentController = userController;
            
            return webCfg;
        }
    }
    
    var webConfig2:WKWebViewConfiguration {
        get {
            let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
            let userController:WKUserContentController = WKUserContentController()
            userController.addScriptMessageHandler(self, name: "button2Clicked")
            
            injectScript("Click4", userController: userController);
            
            webCfg.userContentController = userController;
            
            return webCfg;
        }
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
        
        // Create a WKWebView instance
        webView = WKWebView (frame: self.view.frame, configuration: webConfig)
        
        // Delegate to handle navigation of web content
        //webView!.navigationDelegate = self
        
        // Create a WKWebView instance
        webView2 = WKWebView (frame: self.view.frame, configuration: webConfig2)
        
        // Delegate to handle navigation of web content
        //webView2!.navigationDelegate = self
        
        // prekryje JSView s wkwebview
        //view.addSubview(webView!)
        //self.view = self.webView
        
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
