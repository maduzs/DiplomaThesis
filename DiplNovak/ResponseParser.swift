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
    
    private let defaultTextColor = UIColor.black;
    private let defaultBackgroundColor = UIColor.white;
    
    override init(){
        
    }
    
    func parseRenderResponse(sandboxId: Int, className: String, renderResult: NSDictionary) -> [UIClass]{
        var result  = [UIClass]()
        var objClass = className;
        
        if (className.characters.count <= 0){
            if let name : String = renderResult.object(forKey: "className") as? String{
                objClass = name;
            }
        }
        
        if let itemsArray : NSArray = renderResult.object(forKey: "uiElements") as? NSArray{
            result = parseUIElements(sandboxId, objClass: objClass, itemsArray: itemsArray);
        }
        
        return result
    }
    
    fileprivate func parseUIElements(_ sandboxId : Int, objClass: String, itemsArray : NSArray) -> [UIClass]{
        var elementsResult = [UIClass]()
        for (item) in itemsArray {
            
            if let uiClass : UIClass = parseUIElement(sandboxId, objClass: objClass, item: item as AnyObject){
                elementsResult.append(uiClass)
            }
        }
        return elementsResult;
    }
    
    fileprivate func parseUIElement(_ sandboxId : Int, objClass: String, item : AnyObject) -> UIClass?{
        var alpha : CGFloat = 1.0
        
        if (item is NSNull){
            return nil;
        }
        if let objectId : Int = item.object(forKey: "objectId") as? Int{
            if let parseAlpha : CGFloat = item.object(forKey: "alpha") as? CGFloat{
                alpha = parseAlpha
            }
            if let objectType: String = item.object(forKey: "objectType") as? String {
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
    
    func parseUpdateResponseId(_ sandboxId: Int, content: [AnyObject]) -> ([Int : [String: AnyObject]]){
        var resultObjects = [Int : [String : AnyObject]]()
        
        for (i) in 0..<content.count{
            if (content[i] is NSNull){
                continue;
            }
            
            if let objId : Int = content[i].object(forKey: "objectId") as? Int{
                
                var object = [String: AnyObject]()
                
                if let uiObject = parseUIElement(sandboxId, objClass: "", item: content[i]){
                    object["element"] = uiObject;
                }
                else{
                    if let alpha : CGFloat = content[i].object(forKey: "alpha") as? CGFloat{
                        object["alpha"] = alpha as AnyObject?
                    }
                    if let title : String = content[i].object(forKey: "title") as? String{
                        object["title"] = title as AnyObject?
                    }
                    else{
                        if let text : String = content[i].object(forKey: "text") as? String{
                            object["text"] = text as AnyObject?
                        }
                    }
                    
                    if let colorArray : NSArray = content[i].object(forKey: "textColor") as? NSArray{
                        if let color = parseColor(colorArray){
                            object["textColor"] = color;
                        }
                    }
                    
                    if let colorArray : NSArray = content[i].object(forKey: "backgroundColor") as? NSArray{
                        if let color = parseColor(colorArray){
                            object["backgroundColor"] = color;
                        }
                    }
                    if let textAlignmentObject : String = content[i].object(forKey: "textAlignment") as? String{
                        object["textAlignment"] = parseTextAlignment(textAlignmentObject) as AnyObject?;
                    }
                    
                    if let fc = parseFrameOrConstraint(content[i]){
                        let frame = fc.0;
                        let constraints = fc.1;
                        if (constraints.count > 0){
                            object["constraints"] = constraints as AnyObject?;
                        }
                        else{
                            object["frame"] = frame as AnyObject?;
                        }
                    }
                }
                
                if (object.keys.count > 0){
                    resultObjects[objId] = object;
                }
            }
            
        }
        return (resultObjects)
    }
    
    fileprivate func parseButton(_ content : AnyObject, sandboxId: Int, objectId: Int, className: String, alpha: CGFloat) -> UIClass?{
        var title = "";
        if let t : String = content.object(forKey: "title") as? String{
            title = t;
        }
        if let frameConstraint = parseFrameOrConstraint(content){
            
            let cgRect = frameConstraint.0;
            let constraints = frameConstraint.1
            
            let colors = parseAndSetColors(content);
            let textColor = colors.0;
            let backgroundColor = colors.1;
            
            let uiButton :UIButton = factory.createButton(cgRect: cgRect, backgroundColor: backgroundColor, textColor: textColor, title : title, state: UIControlState(), alpha: alpha)
            
            if let uiClass : UIClass = parseButtonAction(content, sandboxId: sandboxId, objectId: objectId, className: className, constraints: constraints, uiButton: uiButton){
                return uiClass;
            }
            
        }
        return nil
    }
    
    fileprivate func parseLabel(_ content: AnyObject, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
        var text = "";
        if let t : String = content.object(forKey: "text") as? String{
            text = t;
        }
        if let frameConstraint = parseFrameOrConstraint(content){
            
            let cgRect = frameConstraint.0;
            let constraints = frameConstraint.1
            
            
            let colors = parseAndSetColors(content);
            let textColor = colors.0;
            let backgroundColor = colors.1;
            
            var textAlignment : NSTextAlignment?;
            if let textAlignmentObject : String = content.object(forKey: "textAlignment") as? String{
                textAlignment = parseTextAlignment(textAlignmentObject);
            }
            
            let uiLabel = factory.createLabel(cgRect, backgroundColor : backgroundColor, textColor : textColor, textAlignment: textAlignment, text: text, alpha: alpha)
            
            let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], constraints: constraints, uiElement: uiLabel)
            
            return uiClass
        }
        return nil
    }
    
    fileprivate func parseTextField(_ content: AnyObject, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
        var text = "";
        if let t : String = content.object(forKey: "text") as? String{
            text = t;
        }
        if let frameConstraint = parseFrameOrConstraint(content){
            
            let cgRect = frameConstraint.0;
            let constraints = frameConstraint.1
            
            let colors = parseAndSetColors(content);
            let textColor = colors.0;
            let backgroundColor = colors.1;

            var textAlignment : NSTextAlignment?;
            if let textAlignmentObject : String = content.object(forKey: "textAlignment") as? String{
                textAlignment = parseTextAlignment(textAlignmentObject);
            }
            
            let uiTextField = factory.createTextField(cgRect, text: text, backgroundColor : backgroundColor, textColor: textColor, textAlignment: textAlignment, alpha: alpha)
            
            let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], constraints: constraints, uiElement: uiTextField)
            
            return uiClass
        }
        return nil
    }
    
    fileprivate func parseTextView(_ content: AnyObject, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
        var text = "";
        if let t : String = content.object(forKey: "text") as? String{
            text = t;
        }
        if let frameConstraint = parseFrameOrConstraint(content){
            
            let cgRect = frameConstraint.0;
            let constraints = frameConstraint.1
            
            let colors = parseAndSetColors(content);
            let textColor = colors.0;
            let backgroundColor = colors.1;
            
            var textAlignment : NSTextAlignment?;
            if let textAlignmentObject : String = content.object(forKey: "textAlignment") as? String{
                textAlignment = parseTextAlignment(textAlignmentObject);
            }
            
            let uiTextView : UITextView = factory.createTextView(cgRect, text: text, backgroundColor : backgroundColor, textColor: textColor, textAlignment: textAlignment, alpha: alpha)
            
            let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], constraints: constraints, uiElement: uiTextView)
            
            return uiClass
        }
        return nil
    }
    
    fileprivate func parseFrameOrConstraint(_ content: AnyObject) -> (CGRect, [AnyObject])? {
        var cgRect = CGRect(x: 0, y: 0, width: 0, height: 0);
        var constraints = [AnyObject]();
        var rect = true;
        if let frame : CGRect = parseObjectFrame(content){
            cgRect = frame
        }
        else{
            rect = false;
        }
        if let constraintsParse : [AnyObject] = parseObjectConstraints(content){
            constraints = constraintsParse;
        }
        // constraints override the frame
        if (constraints.count > 0){
            cgRect = CGRect(x: 0, y: 0, width: 0, height: 0);
        }
        else{
            if (!rect){
                return nil;
            }
        }
        return (cgRect, constraints);
    }
    
    fileprivate func parseObjectFrame(_ content: AnyObject) -> CGRect?{
        if let frame : NSDictionary = content.object(forKey: "frame") as? NSDictionary {
            if  let width : Int = frame.object(forKey: "width") as? Int,
                    let height : Int = frame.object(forKey: "height") as? Int,
                    let x : Int = frame.object(forKey: "x") as? Int,
                    let y : Int = frame.object(forKey: "y") as? Int {
                        
                let cgRectLabel = CGRect(x: x, y: y, width: width, height: height)
                return cgRectLabel
            }
        }
        return nil
    }
    
    fileprivate func parseObjectConstraints(_ content: AnyObject) -> [AnyObject]?{
        if let constraintsArray : NSArray = content.object(forKey: "constraints") as? NSArray{
            var constraints = [AnyObject]();
            for (i) in 0..<constraintsArray.count{
                if let _ : String = (constraintsArray[i] as AnyObject).object(forKey: "anchor") as? String {
                    constraints.append(constraintsArray[i] as AnyObject)
                }
            }
            return constraints;
        }
        return nil;
    }
    
    fileprivate func parseAndSetColors(_ content: AnyObject) -> (textColor: UIColor, backgroundColor: UIColor){
        var textColor = defaultTextColor;
        var backgroundColor = defaultBackgroundColor;
        if let colorArray : NSArray = content.object(forKey: "textColor") as? NSArray{
            if let color = parseColor(colorArray){
                textColor = color;
            }
        }
        if let colorArray : NSArray = content.object(forKey: "backgroundColor") as? NSArray{
            if let color = parseColor(colorArray){
                backgroundColor = color;
            }
        }
        return (textColor, backgroundColor);
    }
    
    fileprivate func parseColor(_ content: NSArray) -> UIColor?{
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
    
    fileprivate func parseTextAlignment(_ content: String) -> NSTextAlignment?{
        var textAlignment : NSTextAlignment?;
        switch (content){
            case "center", "Center" : textAlignment = NSTextAlignment.center;
            case "left", "Left" : textAlignment = NSTextAlignment.left;
            case "right", "Right" : textAlignment = NSTextAlignment.right;
            case "natural", "Natural" : textAlignment = NSTextAlignment.natural;
            case "justified", "Justified" : textAlignment = NSTextAlignment.justified;
            
            default : return nil;
        }
        return textAlignment;
    }
    
    fileprivate func parseButtonAction(_ content : AnyObject, sandboxId : Int, objectId:Int, className : String, constraints : [AnyObject], uiButton : UIButton) -> UIClass?{
        var functionName = ""
        var params = [AnyObject]()
        
        if let fn : String = content.object(forKey: "onClick") as? String {
            functionName = fn;
            if let paramsArray : NSArray = content.object(forKey: "params") as? NSArray{
                for (paramOjb) in paramsArray{
                    print(paramOjb)
                    print((paramOjb as AnyObject).description);
                    if (paramOjb is NSDictionary){
                        
                        // encode dictionary to JSON
                        let jsonData = try! JSONSerialization.data(withJSONObject: paramOjb, options: JSONSerialization.WritingOptions.prettyPrinted)
                        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                        
                        params.append(jsonString as AnyObject)
                        
                    }
                    else{
                        params.append(paramOjb as AnyObject)
                    }
                }
            }
        }
        
        let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: className, functionName: functionName, params: params, constraints: constraints, uiElement: uiButton)
        
        return uiClass;
    }
    
    func parseDeleteResponse(_ content: [AnyObject]) -> [Int]{
        var ids = [Int]();
        for (i) in 0..<content.count{
            if let obj : NSDictionary = content[i] as? NSDictionary{
                if let objId = obj.object(forKey: "objectId") as? Int{
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
