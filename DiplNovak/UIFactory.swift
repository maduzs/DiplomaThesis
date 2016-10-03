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
    
    var alpha : CGFloat = 0.8
    
    override init(){
        
    }
    
    func createButton(cgRect : CGRect, color : UIColor, title:String, state: UIControlState) ->UIButton{
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.frame = cgRect
        button.backgroundColor = color
        button.setTitle(title, forState: state)
        button.tag = self.buttonTag;
        button.alpha = self.alpha
        self.buttonTag += 1
        return button
    }
    
    func createLabel(cgRect: CGRect, textColor : UIColor, backgroundColor : UIColor, textAlignment: NSTextAlignment, text: String) ->UILabel{
        let label: UILabel = UILabel()
        label.frame = cgRect
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        label.textAlignment = textAlignment
        label.text = text
        label.alpha = self.alpha
        return label
    }
    
    func createTextField(cgRect : CGRect, text: String, backgroundColor : UIColor) ->UITextField{
        let txtField: UITextField = UITextField()
        txtField.frame = cgRect
        txtField.text = text;
        txtField.textColor = UIColor.whiteColor();
        txtField.backgroundColor = backgroundColor
        txtField.alpha = self.alpha
        return txtField
    }
    
}