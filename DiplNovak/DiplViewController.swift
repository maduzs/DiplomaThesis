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
    
    var webView: WKWebView!
    
    var colors:[String] = ["00CCCC","99FF99","CC99CC","CCFF99","#00CC99","#ccccff","#ecffb3","#b3e6cc","#0066ff","#ffb3b3"];
    
    var webConfig:WKWebViewConfiguration {
        get {
            
            // Create WKWebViewConfiguration instance
            let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
            
            // Setup WKUserContentController instance for injecting user script
            let userController:WKUserContentController = WKUserContentController()
            
            // Add a script message handler for receiving  "buttonClicked" event notifications posted from the JS document using window.webkit.messageHandlers.buttonClicked.postMessage script message
            userController.addScriptMessageHandler(self, name: "buttonClicked")
            
            // Get script that's to be injected into the document
            let js:String = addButtonScript()
            
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
        
        // prekryje JSView s wkwebview
        view.addSubview(webView!)
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
    
    func loadHtml() {
        let mainBundle:NSBundle = NSBundle(forClass: DiplViewController.self)

        if let htmlPath = mainBundle.pathForResource("TestFile", ofType: "html") {
            let requestUrl = NSURLRequest(URL: NSURL(fileURLWithPath: htmlPath))
                webView!.loadRequest(requestUrl)
        }
        else {
            showAlertWithMessage("Could not load HTML File!")
        }
    }
    
    // WKScriptMessageHandler Delegate
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let messageBody:NSDictionary = message.body as? NSDictionary {
            let idOfTappedButton:String = messageBody["ButtonId"] as! String
            updateColorOfButtonWithId(idOfTappedButton)
        }
        
    }
    
    // Update color of Button with specified Id
    func updateColorOfButtonWithId(buttonId:String) {
        let count:UInt32 = UInt32(colors.count)
        let index:Int = Int(arc4random_uniform(count))
        let color:String = colors [index]
        
        // Script that changes the color of tapped button
        let js2:String = String(format: "var button = document.getElementById('%@'); button.style.backgroundColor='%@'; ", buttonId,color)
        
        webView!.evaluateJavaScript(js2, completionHandler: { (AnyObject, NSError) -> Void in
            NSLog("button tapped: " + buttonId, __FUNCTION__)
            
        })
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
