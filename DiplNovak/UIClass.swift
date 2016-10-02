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
    var params : [String]
    var uiElement : UIView
    
    init(sandboxId: Int, objectId: Int, className: String, functionName : String, params: [String], uiElement: UIView){
        self.sandboxId = sandboxId
        self.objectId = objectId
        self.className = className
        self.functionName = functionName
        self.params = params
        self.uiElement = uiElement
    }
     
}