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
    
    // al UI elements, 2D
    fileprivate var uiObjects = [[Int : UIClass]()];
    
    fileprivate let scriptMessageHandler = "callbackHandler";
    
    fileprivate let jsapi = "JSAPI"
    
    fileprivate let jsCommunicator = "JS_COMMUNICATOR";
    
    fileprivate let buttonAction = "buttonAction:"
    
    fileprivate let dismissKeyboardMethodName = "dismissKeyboard"
    
    fileprivate let sandboxManager: SandboxManager = SandboxManager(handlerName: "callbackHandler", apiFileName: "JSAPI", scriptCommunicatorName: "JS_COMMUNICATOR");
    
    fileprivate var myGroup = DispatchGroup()
    
    fileprivate var consoleShow = false;
    
    fileprivate var screenSize: CGRect?;
    
    fileprivate var screenWidth : CGFloat?;
    
    fileprivate var screenHeight : CGFloat?;
    
    struct defaultsKeys {
        static let keyOne = "inputKey"
    }
    
    // severity - 0 : trace, 1 : warning, 2 : error
    func debugInfo(_ sandboxId: Int, content: String, severity: Int) {
        
        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        
        switch(severity){
            
        case 0 :
            containerView.debugTextView.text = containerView.debugTextView.text + String(hour) + ":" + String(minutes) + " | Trace: " + content + "\r\n";
            break
        case 1 :
            containerView.debugTextView.text = containerView.debugTextView.text + String(hour) + ":" +  String(minutes) + " | Warning: " + content + "\r\n";
            if (containerView.debugTextView.isHidden) {
                let image : UIImage = (UIImage(named: "console-Importance_50") as UIImage?)!
                containerView.consoleButton.setBackgroundImage(image, for: UIControlState())
            }
            break
    
        case 2 :
            hideAllSubview(true);
            consoleShow = true;
            containerView.debugTextView.isHidden = false;
            setConsoleIcon();
            containerView.debugTextView.text = containerView.debugTextView.text + String(hour) + ":" +  String(minutes) + " | Error: " + content + "\r\n";
        default: break;
        }
    }
    
    func addUIElement(_ sandboxId : Int, content : [UIClass]){
        addSubview(sandboxId, objects: content);
    }
    
    var count = 0;

    func updateUIElement(_ sandboxId : Int, content : [Int: [String : AnyObject]]){
        for (contentKey, contentValue) in content {
            
            if let uiObject = self.uiObjects[sandboxId][contentKey]{
                for (objectKey, objectValue) in contentValue{

                    if (objectKey == "element"){
                        if objectValue is UIClass{
                            self.removeSubview(sandboxId, id: contentKey);
                            self.addSubview(sandboxId, objects: [objectValue as! UIClass]);
                            uiObject.uiElement = objectValue.uiElement;
                        }
                    }
                    else{
                        if (uiObject.uiElement is UIButton){
                            updateButton(objectKey: objectKey, objectValue: objectValue, object: uiObject.uiElement as! UIButton);
                        }
                        else{
                            if (uiObject.uiElement is UITextView){
                                updateTextView(objectKey: objectKey, objectValue: objectValue, object: uiObject.uiElement as! UITextView);
                            }
                            else{
                                if (uiObject.uiElement is UITextField){
                                    updateTextField(objectKey: objectKey, objectValue: objectValue, object: uiObject.uiElement as! UITextField);
                                }
                                else{
                                    if (uiObject.uiElement is UILabel){
                                        updateLabel(objectKey: objectKey, objectValue: objectValue, object: uiObject.uiElement as! UILabel);
                                    }
                                    else{
                                        return;
                                    }
                                }
                            }
                        }
                        if (objectKey == "alpha" && objectValue is CGFloat){
                            uiObject.uiElement.alpha = (objectValue as! CGFloat);
                        }
                        
                        if (objectKey == "backgroundColor" && objectValue is UIColor){
                            uiObject.uiElement.backgroundColor = (objectValue as! UIColor);
                        }
                        if (objectKey == "constraints" && objectValue is [AnyObject]){
                            if (objectValue.count > 0){
                                uiObject.uiElement.translatesAutoresizingMaskIntoConstraints = false
                                setConstraints(sandboxId, object: uiObject.uiElement, constraints: objectValue as! [AnyObject])
                            }
                        }
                        else{
                            if (objectKey == "frame" && objectValue is CGRect){
                                uiObject.uiElement.frame = objectValue as! CGRect;
                            }
                        }
                    }
                }
            }
            else{
                debugInfo(sandboxId, content: "no elements with id: " + String(contentKey) + " to change!", severity: 1)
            }
        }
    }
    
    fileprivate func updateButton(objectKey: String, objectValue: AnyObject, object: UIButton){
        if (objectKey == "title"){
            object.setTitle(objectValue.description, for: UIControlState())
        }
        if (objectKey == "textColor" && objectValue is UIColor){
            object.setTitleColor(objectValue as? UIColor, for: UIControlState())
        }
    }
    fileprivate func updateTextField(objectKey: String, objectValue: AnyObject, object: UITextField){
        if (objectKey == "text"){
            object.text = objectValue.description
        }
        if (objectKey == "textColor" && objectValue is UIColor){
            object.textColor = objectValue as? UIColor
        }
        if (objectKey == "textAlignment"){
            object.textAlignment = objectValue as! NSTextAlignment
        }
    }
    fileprivate func updateTextView(objectKey: String, objectValue: AnyObject, object: UITextView){
        if (objectKey == "text"){
            object.text = objectValue.description
        }
        if (objectKey == "textColor" && objectValue is UIColor){
            object.textColor = objectValue as? UIColor
        }
        if (objectKey == "textAlignment"){
            object.textAlignment = objectValue as! NSTextAlignment
        }
    }
    fileprivate func updateLabel(objectKey: String, objectValue: AnyObject, object: UILabel){
        if (objectKey == "text"){
            object.text = objectValue.description
        }
        if (objectKey == "textColor" && objectValue is UIColor){
            object.textColor = objectValue as? UIColor
        }
        if (objectKey == "textAlignment"){
            object.textAlignment = objectValue as! NSTextAlignment
        }
    }

    func removeUIElement(_ sandboxId : Int, uiElementId: [Int]){
        for id in uiElementId {
            removeSubview(sandboxId, id: id);
        }
    }
    
    // system buttons in view, not from JS
    func execute(_ buttonId : Int, content: String){
        switch (buttonId){
        case 0 :

            containerView.debugTextView.text = "";
            containerView.debugTextView.isHidden = true;
            
            startLoadingSpinner();

            
            var err = false;
            
            // multiple URLs
            if let multiUrl : [String] = checkInputMultiple(content){
                if Reachability.isConnectedToNetwork() == true {
                
                    for (_) in 0..<multiUrl.count{
                    
                        myGroup.enter()
                    
                        let urlGet = URL(string: multiUrl[0])
                        var dataString:String = ""
                        
                        let task = URLSession.shared.dataTask(with: urlGet!, completionHandler: {(data, response, error) in
                        // URL content response
                            if (error == nil && data != nil){
                                dataString = String(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
                            
                                DispatchQueue.main.async {
                                    // Update the UI on the main thread.
                                    self.didReceiveUrlContent(dataString)
                                    self.myGroup.leave()
                                };
                            }
                            else{
                                err = true;
                                self.showAlertWithMessage("Content of the URL is not valid!")
                                self.myGroup.leave()
                            }
                        })
                    
                        task.resume()
                    }
                
                    myGroup.notify(queue: DispatchQueue.main, execute: {
                        if !err {
                            self.dismiss(animated: false, completion: nil)
                            self.debugInfo(-1, content: "Init request finished", severity: 0)
                        }
                    })
                }
                else{
                    showAlertWithMessage("Internet connection not available! Please connect to the internet.")
                }
                
            }
            // content is a script
            else{
                DispatchQueue.main.async {
                    self.didReceiveUrlContent(content)
                    self.debugInfo(-1, content: "Init request finished", severity: 0)
                    self.dismiss(animated: false, completion: nil)
                };
            }
            
            let defaults = UserDefaults.standard
            
            defaults.setValue(content, forKey: defaultsKeys.keyOne)
            
            defaults.synchronize()

        case 1 :
            containerView.textView1.text = "";
        case 2 :
            hideAllSubview(!consoleShow);
            
            setConsoleIcon();
            
            containerView.debugTextView.isHidden = consoleShow;
            
            consoleShow = !consoleShow;
            
        default :
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = UIScreen.main.bounds;
        screenWidth = screenSize!.width;
        screenHeight = screenSize!.height;
        
        sandboxManager.viewCtrl = self;
        
        loadState();

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector(self.dismissKeyboardMethodName)))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    fileprivate func startLoadingSpinner(){
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setConsoleIcon(){
        var image : UIImage;
        if (consoleShow){
            image = (UIImage(named: "console-100") as UIImage?)!
            containerView.consoleButton.alpha = 1
        }
        else{
            image = (UIImage(named: "console_filled-100") as UIImage?)!
            containerView.consoleButton.alpha = 0.6
        }
        containerView.consoleButton.setBackgroundImage(image, for: UIControlState())
    }
    
    fileprivate func checkInputMultiple(_ input: String) -> [String]? {
        var multiUrl = [String]();
        if input.range(of: ",") != nil{
            multiUrl = input.components(separatedBy: ",");
            for (i) in 0..<multiUrl.count{
                let trimmedString = multiUrl[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if (!verifyUrl(trimmedString)){
                    return nil;
                }
                multiUrl[i] = trimmedString;
            }
        }
        else {
            if input.range(of: "+") != nil{
                multiUrl = input.components(separatedBy: "+");
                for (i) in 0..<multiUrl.count{
                    let trimmedString = multiUrl[i].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
    fileprivate func loadState(){
        let defaults = UserDefaults.standard
        
        if let stringOne = defaults.string(forKey: defaultsKeys.keyOne){
            if (stringOne.characters.count > 0){
                containerView.textView1.text = stringOne
            }
        }
    }

    // process the URL content
    fileprivate func didReceiveUrlContent(_ urlContent: String) {
        
        var newSandboxId = -1;
        
        sandboxManager.createSandbox(self.view, scriptNames: [], content: urlContent) {(newId) -> Void in
            
            newSandboxId = newId
            
            if (newSandboxId < 0){
                self.debugInfo(-1, content: "Sandbox creation error!", severity: 2)
                return;
            }
            self.uiObjects.append([Int : UIClass]());
            
            self.sandboxManager.initFromUrl(newSandboxId, urlContent: urlContent) {(scriptNames) -> Void in
                
                if (scriptNames.count <= 0){
                    self.debugInfo(-1, content: "Scripts initialization error!", severity: 2)
                    return;
                }
                    
                for (script) in scriptNames {
                    self.sandboxManager.executeRender(newSandboxId, className: script) {(objects) -> Void in
                        
                        if (objects.count <= 0){
                            self.debugInfo(-1, content: "Objects initialization warning: No objects to render!", severity: 1)
                            return;
                        }
                        
                        self.addSubview(newSandboxId, objects: objects)

                    }
                }
            }
        }
    }
    
    fileprivate func addSubview(_ sandboxId : Int, objects: [UIClass]){
        for (object) in objects {
            if let btn = object.uiElement as? UIButton {
                btn.addTarget(self, action: Selector(self.buttonAction), for: UIControlEvents.touchUpInside)
            }
            if (self.checkIds(sandboxId, id: object.objectId)){
                self.uiObjects[sandboxId][object.objectId] = object
                if (object.constraints.count > 0){
                    object.uiElement.translatesAutoresizingMaskIntoConstraints = false
                }
                self.view.addSubview(object.uiElement)
                if (object.constraints.count > 0){
                    setConstraints(sandboxId, object: object.uiElement, constraints: object.constraints)
                }
            }
            else {
                debugInfo(sandboxId, content: "Non unique Id of object!" + " objectId: "
                    + String(object.objectId), severity: 1);
                if (self.containerView.debugTextView.isHidden){
                    let image : UIImage = (UIImage(named: "console-Importance_50") as UIImage?)!
                    containerView.consoleButton.setBackgroundImage(image, for: UIControlState())
                }
            }
        }
    }
    
    fileprivate func setConstraints(_ sandboxId: Int, object: UIView, constraints: [AnyObject]) {
        for (i) in 0..<constraints.count {
            var toObjectId = -1;
            var constant : CGFloat = 0.0;
            if let anchor : String = constraints[i].object(forKey: "anchor") as? String{
                if let oId = constraints[i].object(forKey: "toObjectId") as? Int{
                    toObjectId = oId;
                }
                if let c : CGFloat = constraints[i].object(forKey: "constant") as? CGFloat{
                    constant = c;
                }
                setConstraint(sandboxId, object: object, anchor: anchor, constant: constant, toObjectId: toObjectId);
            }
        }
    }
    
    fileprivate func setConstraint(_ sandboxId: Int, object: UIView, anchor: String, constant: CGFloat, toObjectId: Int){
        var toObject = UIView();
        if (toObjectId > 0){
            if let obj : UIView = self.uiObjects[sandboxId][toObjectId]?.uiElement{
                toObject = obj;
            }
            else{
                return;
            }
        }
        switch (anchor){
            case "bottom" :
                if (toObjectId > 0){
                    object.bottomAnchor.constraint(equalTo: toObject.bottomAnchor, constant: constant).isActive = true
                }
                else{
                    object.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant).isActive = true
                }
            case "centerX" :
                if (toObjectId > 0){
                    object.centerXAnchor.constraint(equalTo: toObject.centerXAnchor, constant: constant).isActive = true
                }
                else{
                    object.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
                }
            case "centerY" :
                if (toObjectId > 0){
                    object.centerYAnchor.constraint(equalTo: toObject.centerYAnchor, constant: constant).isActive = true
                }
                else{
                    object.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
                }
            case "height" :
                if (toObjectId > 0){
                    object.heightAnchor.constraint(equalTo: toObject.heightAnchor, constant: constant).isActive = true
                }
                else{
                    object.heightAnchor.constraint(equalToConstant: constant).isActive = true
                }
            case "leading" :
                if (toObjectId > 0){
                    object.leadingAnchor.constraint(equalTo: toObject.leadingAnchor, constant: constant).isActive = true
                }
                else{
                    object.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant).isActive = true
                }
            case "left" :
                if (toObjectId > 0){
                    object.leftAnchor.constraint(equalTo: toObject.leftAnchor, constant: constant).isActive = true
                }
                else{
                    object.leftAnchor.constraint(equalTo: view.leftAnchor, constant: constant).isActive = true
                }
            case "right" :
                if (toObjectId > 0){
                    object.rightAnchor.constraint(equalTo: toObject.rightAnchor, constant: constant).isActive = true
                }
                else{
                    object.rightAnchor.constraint(equalTo: view.rightAnchor, constant: constant).isActive = true
                }
            case "top" :
                if (toObjectId > 0){
                    object.topAnchor.constraint(equalTo: toObject.topAnchor, constant: constant).isActive = true
                }
                else{
                    object.topAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
                }
            case "trailing" :
                if (toObjectId > 0){
                    object.trailingAnchor.constraint(equalTo: toObject.trailingAnchor, constant: constant).isActive = true
                }
                else{
                    object.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant).isActive = true
                }
            case "width" :
                if (toObjectId > 0){
                    object.widthAnchor.constraint(equalTo: toObject.widthAnchor, constant: constant).isActive = true
                }
                else{
                    object.widthAnchor.constraint(equalToConstant: constant).isActive = true
                }
            
            default :
                return;
            
        }
    }
    
    fileprivate func hideAllSubview(_ hide : Bool){
        if (hide){
            for (i) in 0..<uiObjects.count{
                for (key, _) in uiObjects[i]{
                    containerView.sendSubview( toBack: uiObjects[i][key]!.uiElement );
                }
            }
        }
        else{
            for (i) in 0..<uiObjects.count{
                for (key, _) in uiObjects[i]{
                    containerView.bringSubview( toFront: uiObjects[i][key]!.uiElement );
                }
            }
        }
    }
    
    fileprivate func removeSubview(_ sandboxId: Int, id : Int){
        if let element = uiObjects[sandboxId][id] {
            element.uiElement.removeFromSuperview();
            uiObjects[sandboxId].removeValue(forKey: id)
        }
        else{
            self.debugInfo(sandboxId, content: "Nothing to delete!", severity: 1);
        }
    }
    
    fileprivate func verifyUrl (_ urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    // checks if the received id is unique in UI
    fileprivate func checkIds(_ sandboxId: Int, id : Int) -> Bool{
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

    // every user inserted button action has this function registered. This function is called after user inserted button tap
    func buttonAction(_ sender: UIButton!) {
        
        debugInfo(-1, content: "Button tapped! ", severity: 0);
        
        /// iterate over sandboxes, select one with desired tag in it
        for (i) in 0..<uiObjects.count {
            for (key, value) in uiObjects[i]{
                if (value.uiElement.tag == sender.tag){
                    if let object = uiObjects[i][key]{
                        
                        debugInfo(-1, content: "Button tapped! " + " objId: " + String(object.objectId) + " title: " + sender.currentTitle! , severity: 0);
                        
                        let multiClassCall = object.functionName.components(separatedBy: ".");
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
        for case let textView as UITextView in self.view.subviews {
            textView.resignFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //autoclose message
    func showMessageAutoclose(_ del: Double, title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        let delay = del * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            alertController.dismiss(animated: true, completion: nil)
        })
    }
    
    // Helper
    func showAlertWithMessage(_ message:String) {
        // first, dismiss any animated stuff in background
        self.dismiss(animated: false){ (data) in
            let alertAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: { () -> Void in
                    
                })
            }
            
            let alertView:UIAlertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alertView.addAction(alertAction)
            
            self.present(alertView, animated: true, completion: { () -> Void in
                
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
