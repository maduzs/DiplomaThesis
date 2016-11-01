//
//  ResponseParser.swift
//  DiplNovak
//
//  Created by Novak Second on 24/06/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import Foundation
import UIKit

class ResponseParser: NSObject{
    
    let factory = UIFactory();
    
    override init(){
        
    }
    
    func parseRenderResponse(sandboxId: Int, className: String, renderResult: NSDictionary) -> [UIClass]{
        var result  = [UIClass]()
        var objClass = className;
        
        if (className.characters.count <= 0){
            if let name : String = renderResult.objectForKey("className") as? String{
                objClass = name;
            }
        }
        
        if let itemsArray : NSArray = renderResult.objectForKey("uiElements") as? NSArray{
            result = parseUIElements(sandboxId, objClass: objClass, itemsArray: itemsArray);
        }
        
        return result
    }
    
    private func parseUIElements(sandboxId : Int, objClass: String, itemsArray : NSArray) -> [UIClass]{
        var elementsResult = [UIClass]()
        for (item) in itemsArray {
            
            if let uiClass : UIClass = parseUIElement(sandboxId, objClass: objClass, item: item){
                elementsResult.append(uiClass)
            }
        }
        return elementsResult;
    }
    
    private func parseUIElement(sandboxId : Int, objClass: String, item : AnyObject) -> UIClass?{
        var alpha : CGFloat = 1.0
        
        if (item is NSNull){
            return nil;
        }
        if let objectId : Int = item.objectForKey("objectId") as? Int{
            if let parseAlpha : CGFloat = item.objectForKey("alpha") as? CGFloat{
                alpha = parseAlpha
            }
            if let objectType: String = item.objectForKey("objectType") as? String {
                if (objectType == "button"){
                    if let uiClass : UIClass = parseButton(item, sandboxId: sandboxId, objectId: objectId, className: objClass, alpha: alpha){
                        return uiClass
                    }
                }
                
                if (objectType == "label"){
                    if let uiClass : UIClass = parseLabel(item, sandboxId: sandboxId, objectId: objectId, alpha: alpha){
                        return uiClass
                    }
                }
                
                if (objectType == "textField"){
                    if let uiClass : UIClass = parseTextField(item, sandboxId: sandboxId, objectId: objectId, alpha: alpha){
                        return uiClass
                    }
                }
                if (objectType == "textView"){
                    if let uiClass : UIClass = parseTextView(item, sandboxId: sandboxId, objectId: objectId, alpha: alpha){
                        return uiClass
                    }
                }
            }
        }
        return nil
    }
    
    // TODO refactor
    func parseUpdateResponseId(sandboxId: Int, content: [AnyObject]) -> ([Int : [String: AnyObject]]){
        var resultObjects = [Int : [String : AnyObject]]()
        
        for (i) in 0..<content.count{
            if (content[i] is NSNull){
                continue;
            }
            
            if let objId : Int = content[i].objectForKey("objectId") as? Int{
                
                var object = [String: AnyObject]()
                
                if let uiObject = parseUIElement(sandboxId, objClass: "", item: content[i]){
                    object["element"] = uiObject;
                }
                else{
                    if let alpha : CGFloat = content[i].objectForKey("alpha") as? CGFloat{
                        object["alpha"] = alpha
                    }
                    if let title : String = content[i].objectForKey("title") as? String{
                        object["title"] = title
                    }
                    else{
                        if let text : String = content[i].objectForKey("text") as? String{
                            object["text"] = text
                        }
                    }
                    // workaround with CGRect -> AnyObject 
                    if let frame = parseObjectFrame(content[i]){
                        let f = UIClass(sandboxId: sandboxId, objectId: objId);
                        f.uiElement = UIView();
                        f.uiElement.frame = frame;
                        object["frame"] = f;
                    }
                }
                
                if (object.keys.count > 0){
                    resultObjects[objId] = object;
                }
            }
            
        }
        return (resultObjects)
    }
    
    private func parseButton(content : AnyObject, sandboxId: Int, objectId: Int, className: String, alpha: CGFloat) -> UIClass?{
        if let title : String = content.objectForKey("title") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                var textColor : UIColor?;
                if let colorArray : NSArray = content.objectForKey("textColor") as? NSArray{
                    textColor = parseColor(colorArray);
                }
                var backgroundColor : UIColor?;
                if let colorArray : NSArray = content.objectForKey("backgroundColor") as? NSArray{
                    backgroundColor = parseColor(colorArray);
                }
                
                if let uiButton :UIButton = factory.createButton(cgRect, backgroundColor: backgroundColor, textColor: textColor, title : title, state: UIControlState.Normal, alpha: alpha){
                    
                    if let uiClass : UIClass = parseButtonAction(content, sandboxId: sandboxId, objectId: objectId, className: className, uiButton: uiButton){
                        return uiClass;
                    }
                }
            }
        }
        return nil
    }
    
    private func parseLabel(content: AnyObject, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
        if let text : String = content.objectForKey("text") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                var textColor : UIColor?;
                if let colorArray : NSArray = content.objectForKey("textColor") as? NSArray{
                    textColor = parseColor(colorArray);
                }
                var backgroundColor : UIColor?;
                if let colorArray : NSArray = content.objectForKey("backgroundColor") as? NSArray{
                    backgroundColor = parseColor(colorArray);
                }
                var textAlignment : NSTextAlignment?;
                if let textAlignmentObject : String = content.objectForKey("textAlignment") as? String{
                    textAlignment = parseTextAlignment(textAlignmentObject);
                }
                
                let uiLabel = factory.createLabel(cgRect, backgroundColor : backgroundColor, textColor : textColor, textAlignment: textAlignment, text: text, alpha: alpha)
                
                if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], constraints: [], uiElement: uiLabel) {
                    return uiClass
                }
            }
        }
        return nil
    }
    
    private func parseTextField(content: AnyObject, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
        if let text : String = content.objectForKey("text") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                var textColor : UIColor?;
                if let colorArray : NSArray = content.objectForKey("textColor") as? NSArray{
                    textColor = parseColor(colorArray);
                }
                var backgroundColor : UIColor?;
                if let colorArray : NSArray = content.objectForKey("backgroundColor") as? NSArray{
                    backgroundColor = parseColor(colorArray);
                }
                var textAlignment : NSTextAlignment?;
                if let textAlignmentObject : String = content.objectForKey("textAlignment") as? String{
                    textAlignment = parseTextAlignment(textAlignmentObject);
                }
                
                let uiTextField = factory.createTextField(cgRect, text: text, backgroundColor : backgroundColor, textColor: textColor, textAlignment: textAlignment, alpha: alpha)
                
                if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], constraints: [], uiElement: uiTextField){
                    return uiClass
                }
            }
        }
        return nil
    }
    
    private func parseTextView(content: AnyObject, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
        if let text : String = content.objectForKey("text") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                
                var textColor : UIColor?;
                if let colorArray : NSArray = content.objectForKey("textColor") as? NSArray{
                    textColor = parseColor(colorArray);
                }
                var backgroundColor : UIColor?;
                if let colorArray : NSArray = content.objectForKey("backgroundColor") as? NSArray{
                    backgroundColor = parseColor(colorArray);
                }
                var textAlignment : NSTextAlignment?;
                if let textAlignmentObject : String = content.objectForKey("textAlignment") as? String{
                    textAlignment = parseTextAlignment(textAlignmentObject);
                }
                
                if let uiTextView : UITextView = factory.createTextView(cgRect, text: text, backgroundColor : backgroundColor, textColor: textColor, textAlignment: textAlignment, alpha: alpha){
                    
                    if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], constraints: [], uiElement: uiTextView){
                        return uiClass
                    }
                }
            }
        }
        return nil
    }
    
    private func parseObjectFrame(content: AnyObject) -> CGRect?{
        if let frame : NSDictionary = content.objectForKey("frame") as? NSDictionary {
            if  let width : Int = frame.objectForKey("width") as? Int,
                    height : Int = frame.objectForKey("height") as? Int,
                    x : Int = frame.objectForKey("x") as? Int,
                    y : Int = frame.objectForKey("y") as? Int {
                        
                let cgRectLabel = CGRect(x: x, y: y, width: width, height: height)
                return cgRectLabel
            }
        }
        return nil
    }
    
    private func parseColor(content: NSArray) -> UIColor?{
        if (content.count == 4){
            if let r : CGFloat = content[0] as? CGFloat{
                if let g : CGFloat = content[1] as? CGFloat{
                    if let b : CGFloat = content[2] as? CGFloat{
                        if let a : CGFloat = content[3] as? CGFloat{
                            return UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: a);
                        }
                    }
                }
            }
        }
        return nil;
    }
    
    private func parseTextAlignment(content: String) -> NSTextAlignment?{
        var textAlignment : NSTextAlignment?;
        switch (content){
            case "center", "Center" : textAlignment = NSTextAlignment.Center;
            case "left", "Left" : textAlignment = NSTextAlignment.Left;
            case "right", "Right" : textAlignment = NSTextAlignment.Right;
            case "natural", "Natural" : textAlignment = NSTextAlignment.Natural;
            case "justified", "Justified" : textAlignment = NSTextAlignment.Justified;
            
            default : return nil;
        }
        return textAlignment;
    }
    
    private func parseButtonAction(content : AnyObject, sandboxId : Int, objectId:Int, className : String, uiButton : UIButton) -> UIClass?{
        var functionName = ""
        var params = [AnyObject]()
        
        if let fn : String = content.objectForKey("onClick") as? String {
            functionName = fn;
            if let paramsArray : NSArray = content.objectForKey("params") as? NSArray{
                for (paramOjb) in paramsArray{
                    print(paramOjb)
                    print(paramOjb.description);
                    if (paramOjb is NSDictionary){
                        
                        // encode dictionary to JSON
                        let jsonData = try! NSJSONSerialization.dataWithJSONObject(paramOjb, options: NSJSONWritingOptions.PrettyPrinted)
                        let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
                        
                        params.append(jsonString)
                        
                    }
                    else{
                        params.append(paramOjb)
                    }
                }
            }
        }
        
        if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: className, functionName: functionName, params: params, constraints: [], uiElement: uiButton){
            return uiClass;
        }
        return nil
    }
    
    func parseDeleteResponse(content: [AnyObject]) -> [Int]{
        var ids = [Int]();
        for (i) in 0..<content.count{
            if let obj : NSDictionary = content[i] as? NSDictionary{
                if let objId = obj.objectForKey("objectId") as? Int{
                    ids.append(objId);
                }
            }
            else {
                if let objId = content[i] as? Int {
                    ids.append(objId)
                }
            }
        }
        
        return ids;
    }
    
}
