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
    
    func parseResponse(){
        
    }
    
    func parseRenderResponse(sandboxId: Int, className: String, renderResult: NSDictionary) -> [UIClass]{
        var result  = [UIClass]()
        
        var alpha : CGFloat = 1.0
        
        var objClass = className;
        if (className.characters.count <= 0){
            if let name : String = renderResult.objectForKey("className") as? String{
                objClass = name;
            }
        }
        
        if let itemsArray : NSArray = renderResult.objectForKey("uiElements") as? NSArray{
            
            for (item) in itemsArray {
                if let content: NSDictionary = item.objectForKey("button") as? NSDictionary {
                    if let objectId : Int = content.objectForKey("objectId") as? Int{
                        if let parseAlpha : CGFloat = content.objectForKey("alpha") as? CGFloat{
                            alpha = parseAlpha
                        }
                        if let uiClass : UIClass = parseButton(content, sandboxId: sandboxId, objectId: objectId, className: objClass, alpha: alpha){
                            result.append(uiClass)
                        }
                    }
                    continue;
                }
                if let content: NSDictionary = item.objectForKey("label") as? NSDictionary {
                    if let objectId : Int = content.objectForKey("objectId") as? Int{
                        if let parseAlpha : CGFloat = content.objectForKey("alpha") as? CGFloat{
                            alpha = parseAlpha
                        }
                        if let uiClass : UIClass = parseLabel(content, sandboxId: sandboxId, objectId: objectId, alpha: alpha){
                            result.append(uiClass)
                        }
                    }
                    continue
                }
                if let content: NSDictionary = item.objectForKey("textfield") as? NSDictionary {
                    if let objectId : Int = content.objectForKey("objectId") as? Int{
                        if let parseAlpha : CGFloat = content.objectForKey("alpha") as? CGFloat{
                            alpha = parseAlpha
                        }
                        if let uiClass : UIClass = parseTextField(content, sandboxId: sandboxId, objectId: objectId, alpha: alpha){
                            result.append(uiClass)
                        }
                    }
                    continue
                }
            }
        }
        
        return result
    }
    
    private func parseButton(content : NSDictionary, sandboxId: Int, objectId: Int, className: String, alpha: CGFloat) -> UIClass?{
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
    
    private func parseLabel(content: NSDictionary, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
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
    
    private func parseTextField(content: NSDictionary, sandboxId : Int, objectId: Int, alpha: CGFloat) -> UIClass?{
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
    
    private func parseObjectFrame(content: NSDictionary) -> CGRect?{
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
    
    private func parseButtonAction(content : NSDictionary, sandboxId : Int, objectId:Int, className : String, uiButton : UIButton) -> UIClass?{
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
