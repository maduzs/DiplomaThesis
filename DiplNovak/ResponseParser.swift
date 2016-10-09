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
        
        if let itemsArray : NSArray = renderResult.objectForKey("uiElements") as? NSArray{
            
            for (item) in itemsArray {
                if let content: NSDictionary = item.objectForKey("button") as? NSDictionary {
                    if let objectId : Int = content.objectForKey("objectId") as? Int{
                        if let uiClass : UIClass = parseButton(content, sandboxId: sandboxId, objectId: objectId, className: className){
                            result.append(uiClass)
                        }
                    }
                    continue;
                }
                if let content: NSDictionary = item.objectForKey("label") as? NSDictionary {
                    if let objectId : Int = content.objectForKey("objectId") as? Int{
                        if let uiClass : UIClass = parseLabel(content, sandboxId: sandboxId, objectId: objectId){
                            result.append(uiClass)
                        }
                    }
                    continue
                }
                if let content: NSDictionary = item.objectForKey("textfield") as? NSDictionary {
                    if let objectId : Int = content.objectForKey("objectId") as? Int{
                        if let uiClass : UIClass = parseTextField(content, sandboxId: sandboxId, objectId: objectId){
                            result.append(uiClass)
                        }
                    }
                    continue
                }
            }
        }
        
        return result
    }
    
    private func parseButton(content : NSDictionary, sandboxId: Int, objectId: Int, className: String) -> UIClass?{
        if let title : String = content.objectForKey("title") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                
                if let uiButton :UIButton = factory.createButton(cgRect, color: UIColor.blackColor(), title : title, state: UIControlState.Normal){
                    
                    if let uiClass : UIClass = parseButtonAction(content, sandboxId: sandboxId, objectId: objectId, className: className, uiButton: uiButton){
                        return uiClass;
                    }
                }
                
            }
        }
        return nil
    }
    
    private func parseLabel(content: NSDictionary, sandboxId : Int, objectId: Int) -> UIClass?{
        if let text : String = content.objectForKey("text") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                let uiLabel = factory.createLabel(cgRect, textColor : UIColor.blackColor(), backgroundColor : UIColor.whiteColor(), textAlignment: NSTextAlignment.Center, text: text)
                
                if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: "", functionName: "", params: [], uiElement: uiLabel) {
                    return uiClass
                }
            }
        }
        return nil
    }
    
    private func parseTextField(content: NSDictionary, sandboxId : Int, objectId: Int) -> UIClass?{
        if let text : String = content.objectForKey("text") as? String{
            if let cgRect : CGRect = parseObjectFrame(content){
                let uiTextField = factory.createTextField(cgRect, text: text, backgroundColor : UIColor.blackColor())
                
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
                    if let paramDictionary : AnyObject = paramOjb.objectForKey("value"){
                        params.append(paramDictionary)
                    }
                }
            }
        }
        
        if let uiClass : UIClass = UIClass(sandboxId: sandboxId, objectId: objectId, className: className, functionName: functionName, params: params, uiElement: uiButton){
            return uiClass;
        }
        return nil
    }
    
}
