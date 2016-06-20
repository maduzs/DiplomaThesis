//
//  UIFactory.swift
//  DiplNovak
//
//  Created by Novak Second on 18/06/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import Foundation
import UIKit

class UIFactory : NSObject {
    
    var buttonTag = 1;
    
    override init(){
        
    }
    
    func createButton(cgRect : CGRect, cgRect2 : CGRect, color : UIColor, title:String, state: UIControlState) ->UIButton{
        let button = UIButton(frame: cgRect)
        button.frame = cgRect2
        button.backgroundColor = color
        button.setTitle(title, forState: state)
        button.tag = self.buttonTag;
        self.buttonTag++
        return button
    }
    
    func createLabel(cgRect: CGRect, textColor : UIColor, backgroundColor : UIColor, textAlignment: NSTextAlignment, text: String) ->UILabel{
        let label: UILabel = UILabel()
        label.frame = cgRect
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        label.textAlignment = textAlignment
        label.text = text
        return label
    }
    
    func createTextField(cgRect : CGRect, text: String, backgroundColor : UIColor) ->UITextField{
        let txtField: UITextField = UITextField()
        txtField.frame = cgRect
        txtField.text = text;
        txtField.backgroundColor = backgroundColor
        return txtField
    }
    
}