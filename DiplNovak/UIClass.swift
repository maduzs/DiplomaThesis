//
//  ButtonClass.swift
//  DiplNovak
//
//  Created by Novak Second on 20/06/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import Foundation
import UIKit

class UIClass: NSObject{
    
    var sandboxId : Int
    var objectId : Int
    var className : String
    var functionName  : String
    var params : [AnyObject]
    var constraints : [AnyObject]
    var uiElement : UIView
    
    init(sandboxId: Int, objectId: Int, className: String, functionName : String, params: [AnyObject], constraints: [AnyObject], uiElement: UIView){
        self.sandboxId = sandboxId
        self.objectId = objectId
        self.className = className
        self.functionName = functionName
        self.params = params
        self.constraints = constraints
        self.uiElement = uiElement
    }
    
    init(sandboxId: Int, objectId: Int){
        self.sandboxId = sandboxId
        self.objectId = objectId
        self.className = ""
        self.functionName = ""
        self.params = [AnyObject]()
        self.constraints = [AnyObject]()
        self.uiElement = UIView();
    }
     
}
