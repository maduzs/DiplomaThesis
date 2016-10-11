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
    
    var globalTag = 0;
    
    override init(){
        
    }
    
    func createButton(cgRect : CGRect, color : UIColor, title:String, state: UIControlState, alpha : CGFloat) ->UIButton{
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.frame = cgRect
        button.backgroundColor = color
        button.setTitle(title, forState: state)
        button.tag = globalTag;
        self.globalTag += 1;
        button.alpha = alpha
        return button
    }
    
    func createLabel(cgRect: CGRect, textColor : UIColor, backgroundColor : UIColor, textAlignment: NSTextAlignment, text: String, alpha : CGFloat) ->UILabel{
        let label: UILabel = UILabel()
        label.frame = cgRect
        label.textColor = textColor
        label.backgroundColor = backgroundColor
        label.textAlignment = textAlignment
        label.text = text
        label.tag = globalTag
        self.globalTag += 1;
        label.alpha = alpha
        return label
    }
    
    func createTextField(cgRect : CGRect, text: String, backgroundColor : UIColor, alpha : CGFloat) ->UITextField{
        let txtField: UITextField = UITextField()
        txtField.frame = cgRect
        txtField.text = text;
        txtField.textColor = UIColor.whiteColor();
        txtField.backgroundColor = backgroundColor
        txtField.tag = globalTag
        self.globalTag += 1;
        txtField.alpha = alpha
        return txtField
    }
    
}
