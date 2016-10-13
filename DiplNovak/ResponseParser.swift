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

        var alpha : CGFloat = 1.0

        var elementsResult = [UIClass]()
        for (item) in itemsArray {
            // TODO
            //parseUIElement(sandboxId, objClass, item);
            if let objectId : Int = item.objectForKey("objectId") as? Int{
                if let parseAlpha : CGFloat = item.objectForKey("alpha") as? CGFloat{
                    alpha = parseAlpha
                }
                if let objectType: String = item.objectForKey("objectType") as? String {
                    if (objectType == "button"){
                        if let uiClass : UIClass = parseButton(item, sandboxId: sandboxId, objectId: objectId, className: objClass, alpha: alpha){
                            elementsResult.append(uiClass)
                        }
                        continue;
                    }
                    
                    if (objectType == "label"){
                        if let uiClass : UIClass = parseLabel(item, sandboxId: sandboxId, objectId: objectId, alpha: alpha){
                            elementsResult.append(uiClass)
                        }
                        continue
                    }
                    
                    if (objectType == "textField"){
                        if let uiClass : UIClass = parseTextField(item, sandboxId: sandboxId, objectId: objectId, alpha: alpha){
                            elementsResult.append(uiClass)
                        }
                        continue
                    }
                }
            }
        }
        return elementsResult;
    }
    
    // TODO refactor
    func parseUpdateResponseId(sandboxId: Int, content: [AnyObject]) -> ([Int], [[AnyObject]]){
        var resultIds = [Int]()
        var objects = [AnyObject]()
        var resultObjects = [[AnyObject]]()
        
        // tento element aj odosli!
        let elements = parseUIElements(sandboxId, objClass: "", itemsArray: (content as? NSArray)!)
        for (i) in 0..<elements.count{
            resultIds.append(elements[i].objectId)
            objects.append(elements[i])
            resultObjects.append(objects)
        }
        
        for (i) in 0..<content.count{
            if let objId : Int = content[i].objectForKey("objectId") as? Int{
                
                if let alpha : CGFloat = content[i].objectForKey("alpha") as? CGFloat{
                    objects.append(alpha)
                }
                if let title : String = content[i].objectForKey("title") as? String{
                    objects.append(title)
                }
                else{
                    if let text : String = content[i].objectForKey("text") as? String{
                        objects.append(text)
                    }
                }
                // TODO frame -> any object error
                if let frame = parseObjectFrame(content[i]){
                    //objects.append(frame as! AnyObject)
                }
                
                if objects.count > 0 {
                    resultObjects.append(objects);
                    resultIds.append(objId)
                }
            }
            
        }
        return (resultIds, resultObjects)
    }
    
    private func parseButton(content : AnyObject, sandboxId: Int, objectId: Int, className: String, alpha: CGFloat) -> UIClass?{
        if let title : String = content.objectForKey("title") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                
                if let uiButton :UIButton = factory.createButton(cgRect, color: UIColor.blackColor(), title : title, state: UIControlState.Normal, alpha: alpha){
                    
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
                let uiLabel = factory.createLabel(cgRect, textColor : UIColor.blackColor(), backgroundColor : UIColor.whiteColor(), textAlignment: NSTextAlignment.Center, text: text, alpha: alpha)
                
                if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], uiElement: uiLabel) {
                    return uiClass
                }
            }
        }
        return nil
    }
    
    private func parseTextField(content: AnyObject, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
        if let text : String = content.objectForKey("text") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                let uiTextField = factory.createTextField(cgRect, text: text, backgroundColor : UIColor.blackColor(), alpha: alpha)
                
                if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], uiElement: uiTextField){
                    return uiClass
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
        
        if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: className, functionName: functionName, params: params, uiElement: uiButton){
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
