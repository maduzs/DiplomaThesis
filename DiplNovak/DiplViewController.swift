//
//  DiplViewController.swift
//  DiplNovak
//
//  Created by Novak Second on 28/02/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DiplViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, DiplViewDelegate, DiplSandboxDelegate {
    
    @IBOutlet weak var containerView: JSView! {
        didSet {
            containerView.dataSource = self
        }
    }
    
    var webView: WKWebView!
    
    // al UI elements, 2D
    private var uiObjects = [[UIClass]()];
    
    //only buttons (because of tag) 1D
    private var uiButtonObjects = [Int : UIClass]();
    
    private let scriptMessageHandler = "callbackHandler";
    
    private let jsapi = "JSAPI"
    
    private let jsCommunicator = "JS_COMMUNICATOR";
    
    private let buttonAction = "buttonAction:"
    
    private let dismissKeyboardMethodName = "dismissKeyboard"
    
    private let sandboxManager: SandboxManager = SandboxManager(handlerName: "callbackHandler", apiFileName: "JSAPI", scriptCommunicatorName: "JS_COMMUNICATOR");
    
    func executeAS(sandboxId: Int, uiElementId: Int, content: String) {
        print("ide to more " + String(sandboxId));
        print("elId: " + String(uiElementId) + "content: " + content);
        uiObjects[sandboxId][uiElementId].uiElement.backgroundColor = UIColor.blueColor();
    }
    
    // system buttons in view, not from JS
    func executeJS(buttonId : Int, content : String){
        switch (buttonId){
        case 0 :
            print("load")
            
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .Alert)
            
            alert.view.tintColor = UIColor.blackColor()
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            presentViewController(alert, animated: true, completion: nil)
            
            let url = NSURL(string: content)
            var dataString:String = ""
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                //I want to replace this line below with something to save it to a string.
                dataString = String(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
                dispatch_async(dispatch_get_main_queue()) {
                    // Update the UI on the main thread.
                    self.didReceiveUrlContent(dataString)
                    
                    self.dismissViewControllerAnimated(false, completion: nil)
                    
                };
                
            }
            task.resume()
            
        default :
            return
        }
        //containerView.setNeedsDisplay();
    }
    
    private func didReceiveUrlContent(urlContent: String) {
        
        var newSandboxId = -1;
        sandboxManager.createSandbox(self.view, scriptNames: [], content: urlContent) {(newId) -> Void in
            
            newSandboxId = newId
            
            if (newSandboxId < 0){
                return
            }
            self.uiObjects.append([UIClass]());
            
            self.sandboxManager.initFromUrl(newSandboxId, urlContent: urlContent) {(scriptNames) -> Void in
                
                    print("ok");
                    
                    for (script) in scriptNames {
                        self.sandboxManager.executeRender(newSandboxId, className: script) {(objects) -> Void in
                            for (object) in objects {
                                if let btn = object.uiElement as? UIButton {
                                    btn.addTarget(self, action: Selector(self.buttonAction), forControlEvents: UIControlEvents.TouchUpInside)
                                    self.uiButtonObjects[btn.tag] = object;
                                }
                                if (self.checkIds(newSandboxId, id: object.objectId)){
                                    self.uiObjects[newSandboxId].append(object)
                                    self.view.addSubview(object.uiElement)
                                }
                                else {
                                    self.showAlertWithMessage("Error! Non unique Id in objects!")
                                }
                            }
                        }
                    }
                    
                }
                /*try _ = webView.evaluateJavaScript(jsApiInit){ (result, error) in
                 print("ok");
                 
                 }
                 try _ = webView.evaluateJavaScript("var " + jsCommunicator + "= new JSAPI('" + String(apiId) + "');"){ (result, error) in
                 print("ok");
                 
                 }*/
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sandboxManager.viewCtrl = self;
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector(self.dismissKeyboardMethodName))) 
 
    }
    
    private func checkIds(sandboxId: Int, id : Int) -> BooleanType{
        for ui in self.uiObjects[sandboxId] {
            if (ui.objectId == id){
                return false;
            }
            else{
                continue;
            }
        }
        return true;
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped! " + "id: " + String(sender.tag) + " title: " + sender.currentTitle! )
        
        if let object = uiButtonObjects[sender.tag]{
            sandboxManager.executeClassContent(object.sandboxId, className: object.className, functionName: object.functionName, functionParams: object.params)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func dismissKeyboard(){
        containerView.textView1.resignFirstResponder()
        for case let textField as UITextField in self.view.subviews {
            textField.resignFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //autoclose message
    func showMessageAutoclose(del: Double, title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        self.presentViewController(alertController, animated: true, completion: nil)
        let delay = del * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            alertController.dismissViewControllerAnimated(true, completion: nil)
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
