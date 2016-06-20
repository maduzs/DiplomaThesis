//
//  DiplViewController.swift
//  DiplNovak
//
//  Created by Novak Second on 28/02/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import UIKit
import WebKit

class DiplViewController: UIViewController, DiplViewDelegate {
    
    @IBOutlet weak var containerView: JSView! {
        didSet {
            containerView.dataSource = self
        }
    }
    
    private var webViews = [WKWebView]()
    
    private var results = [Int: AnyObject]();
    
    private var buttonTag = 1;
    
    private var uiObjects = [Int : UIClass]();
    
    private let scriptMessageHandler = "callbackHandler";
    
    private let jsapi = "JSAPI"
    
    private let jsCommunicator = "JS_COMMUNICATOR";
    
    private let sandboxManager: SandboxManager = SandboxManager(handlerName: "callbackHandler", apiFileName: "JSAPI", scriptCommunicatorName: "JS_COMMUNICATOR");

    func executeJS(buttonId : Int, content : String){
        switch (buttonId){
        case 0 :
            sandboxManager.executeScript(0, scriptId: 0)
        case 1 :
            sandboxManager.executeScript(0, scriptId: 1)
        case 2 :
            sandboxManager.executeScript(0, scriptId: 2)
        case 3 :
            sandboxManager.executeScript(1, scriptId: 0)
        //case 4 :
            //sandboxManager.executeClassContent(0, className: "test", content: content)
            //sandboxManager.executeRender(0, className: "JS2")
        case 5 :
            sandboxManager.executeContent(0, content: content)
        case 6 :
            sandboxManager.executeContent(1, content: content)
        default :
            return
        }
        //containerView.setNeedsDisplay();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up WKWebView configuration
        var scriptNames = [String]()
        scriptNames.append("JS")
        scriptNames.append("JS2")
        //scriptNames.append("JS3")
        
        let newSandboxId: Int = sandboxManager.createSandbox(self.view, scripts: scriptNames)
        if (newSandboxId < 0){
            return
        }

        sandboxManager.executeRender(newSandboxId, className: "JS2") {(objects) -> Void in
            for (object) in objects {
                if let btn = object.uiElement as? UIButton {
                    btn.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                    //if let button = ButtonClass(sandboxId: 0, className: btn.cl, functionName: <#T##String#>, params: <#T##[String]#>)
                    self.uiObjects[btn.tag] = object;
                }
                self.view.addSubview(object.uiElement)
            }
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard")))
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
        print(sender.tag);
        print(sender.currentTitle);
        //sender.setTitle("test", forState: UIControlState.Normal);
        // sandboxId TODO
        if let object = uiObjects[sender.tag]{
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
