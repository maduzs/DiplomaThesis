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
    private var uiObjects = [[Int : UIClass]()];
    
    private let scriptMessageHandler = "callbackHandler";
    
    private let jsapi = "JSAPI"
    
    private let jsCommunicator = "JS_COMMUNICATOR";
    
    private let buttonAction = "buttonAction:"
    
    private let dismissKeyboardMethodName = "dismissKeyboard"
    
    private let sandboxManager: SandboxManager = SandboxManager(handlerName: "callbackHandler", apiFileName: "JSAPI", scriptCommunicatorName: "JS_COMMUNICATOR");
    
    private var debugContent = "";
    
    private var myGroup = dispatch_group_create()
    
    struct defaultsKeys {
        static let keyOne = "inputKey"
    }
    
    func executeAS(sandboxId: Int, uiElementId: Int, content: String) {
        print("ide to more " + String(sandboxId));
        print("elId: " + String(uiElementId) + "content: " + content);
        uiObjects[sandboxId][uiElementId]!.uiElement.backgroundColor = UIColor.blueColor();
    }
    
    func debugInfo(sandboxId: Int, content: String) {
        debugContent = content;
        print("sandboxId: " + String(sandboxId) + " content: " + content);
        
        containerView.debugTextView.text = containerView.debugTextView.text + content + "\r\n";
        containerView.debugTextView.hidden = false;

    }
    
    func addUIElement(sandboxId : Int, content : [UIClass]){
        for uielem in content{
            view.addSubview(uielem.uiElement)
            uiObjects[sandboxId][uielem.objectId] = uielem
        }
    }
    
    func updateUIElement(sandboxId : Int, uiElementId: [Int], content : NSDictionary){

    }
    
    func deleteUIElement(sandboxId : Int, uiElementId: [Int]){
        for id in uiElementId {
            uiObjects[sandboxId][id]!.uiElement.removeFromSuperview();
            uiObjects[sandboxId].removeValueForKey(id)
        }
    }
    
    // system buttons in view, not from JS
    func execute(buttonId : Int, content: String){
        switch (buttonId){
        case 0 :

            containerView.debugTextView.text = "";
            containerView.debugTextView.hidden = true;
            
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .Alert)
            
            alert.view.tintColor = UIColor.blackColor()
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            presentViewController(alert, animated: true, completion: nil)
            
            var err = false;
            
            // multiple URLs
            if let multiUrl : [String] = checkInputMultiple(content){
                for (i) in 0..<multiUrl.count{
                    
                    dispatch_group_enter(myGroup)
                    
                    let urlGet = NSURL(string: multiUrl[i])
                    var dataString:String = ""
                    
                    let task = NSURLSession.sharedSession().dataTaskWithURL(urlGet!) {(data, response, error) in
                        // URL content response
                        if (error == nil && data != nil){
                            dataString = String(NSString(data: data!, encoding: NSUTF8StringEncoding)!)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                // Update the UI on the main thread.
                                self.didReceiveUrlContent(dataString)
                                dispatch_group_leave(self.myGroup)
                            };
                        }
                        else{
                            err = true;
                            self.showAlertWithMessage("Content of the URL is not valid!")
                            dispatch_group_leave(self.myGroup)
                        }
                    }
                    
                    task.resume()
                }
                
                dispatch_group_notify(myGroup, dispatch_get_main_queue(), {
                    print("Finished all requests.")
                    if !err {
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }
                })
                
            }
            // content is a script
            else{
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.didReceiveUrlContent(content)
                    
                    self.dismissViewControllerAnimated(false, completion: nil)
                };
            }
            
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            defaults.setValue(content, forKey: defaultsKeys.keyOne)
            
            defaults.synchronize()
            
            
            // TODO stuff with subviews
            
            //self.view.insertSubview(self.containerView.debugTextView, aboveSubview: object.uiElement)
            //self.view.bringSubviewToFront(self.containerView.debugTextView)

        case 1 :
            containerView.textView1.text = "";
        default :
            return
        }
        //containerView.setNeedsDisplay();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sandboxManager.viewCtrl = self;
        
        loadState();

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector(self.dismissKeyboardMethodName)))
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func checkInputMultiple(input: String) -> [String]? {
        var multiUrl = [String]();
        if input.rangeOfString(",") != nil{
            multiUrl = input.componentsSeparatedByString(",");
            for (i) in 0..<multiUrl.count{
                let trimmedString = multiUrl[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if (!verifyUrl(trimmedString)){
                    return nil;
                }
                multiUrl[i] = trimmedString;
            }
        }
        else {
            if input.rangeOfString("+") != nil{
                multiUrl = input.componentsSeparatedByString("+");
                for (i) in 0..<multiUrl.count{
                    let trimmedString = multiUrl[i].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if (!verifyUrl(trimmedString)){
                        return nil;
                    }
                    multiUrl[i] = trimmedString;
                }
            }
            // single URL
            else {
                if verifyUrl(input){
                    multiUrl.append(input);
                }
            }
        }
        return multiUrl;
    }
    
    // load saved state
    private func loadState(){
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let stringOne = defaults.stringForKey(defaultsKeys.keyOne){
            if (stringOne.characters.count > 0){
                containerView.textView1.text = stringOne
            }
        }
    }

    private func didReceiveUrlContent(urlContent: String) {
        
        var newSandboxId = -1;
        
        sandboxManager.createSandbox(self.view, scriptNames: [], content: urlContent) {(newId) -> Void in
            
            newSandboxId = newId
            
            if (newSandboxId < 0){
                self.containerView.debugTextView.text = self.containerView.debugTextView.text + "Sandbox creation error!" + "\r\n";
                self.containerView.debugTextView.hidden = false;
                return;
            }
            self.uiObjects.append([Int : UIClass]());
            
            self.sandboxManager.initFromUrl(newSandboxId, urlContent: urlContent) {(scriptNames) -> Void in
                
                if (scriptNames.count <= 0){
                    self.containerView.debugTextView.text = self.containerView.debugTextView.text + "Scripts initialization error!" + "\r\n";
                    self.containerView.debugTextView.hidden = false;
                    return;
                }
                    
                for (script) in scriptNames {
                    self.sandboxManager.executeRender(newSandboxId, className: script) {(objects) -> Void in
                        
                        if (objects.count <= 0){
                            self.containerView.debugTextView.text = self.containerView.debugTextView.text + "Objects initialization error!" + "\r\n";
                            self.containerView.debugTextView.hidden = false;
                            return;
                        }
                        
                        for (object) in objects {
                            if let btn = object.uiElement as? UIButton {
                                btn.addTarget(self, action: Selector(self.buttonAction), forControlEvents: UIControlEvents.TouchUpInside)
                            }
                            if (self.checkIds(newSandboxId, id: object.objectId)){
                                self.uiObjects[newSandboxId][object.objectId] = (object)
                                self.view.addSubview(object.uiElement)
                            }
                            else {
                                self.containerView.debugTextView.text = self.containerView.debugTextView.text + "Error! Non unique Id in objects!" + " objectId: "
                                    + String(object.objectId) + "\r\n";
                                self.containerView.debugTextView.hidden = false;
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    private func checkIds(sandboxId: Int, id : Int) -> BooleanType{
        for (_, value) in self.uiObjects[sandboxId] {
            if (value.objectId == id){
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
        
        /// iterate over sandboxes, select one with desired tag in it
        for (i) in 0..<uiObjects.count {
            for (key, value) in uiObjects[i]{
                if (value.uiElement.tag == sender.tag){
                    if let object = uiObjects[i][key]{
                        
                        let multiClassCall = object.functionName.componentsSeparatedByString(".");
                        if (multiClassCall.count == 2){
                            sandboxManager.executeClassContent(object.sandboxId, className: multiClassCall[0], functionName: multiClassCall[1], functionParams: object.params)
                        }
                        else{
                            if (multiClassCall.count == 1){
                                sandboxManager.executeClassContent(object.sandboxId, className: object.className, functionName: object.functionName, functionParams: object.params)
                            }
                            else {
                                showAlertWithMessage("Wrong button action registered!");
                            }
                        }
                    }
                }
            }
        }
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
        // first, dismiss any animated stuff in background
        self.dismissViewControllerAnimated(false){ (data) in
            let alertAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
            }
            
            let alertView:UIAlertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alertView.addAction(alertAction)
            
            self.presentViewController(alertView, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
