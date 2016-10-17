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
    
    func createButton(cgRect : CGRect, backgroundColor : UIColor?, textColor: UIColor?, title:String, state: UIControlState, alpha : CGFloat) ->UIButton{
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.frame = cgRect
        if (backgroundColor != nil){
            button.backgroundColor = backgroundColor
        }
        if (textColor != nil){
            button.setTitleColor(textColor, forState: UIControlState.Normal)
        }
        button.setTitle(title, forState: state)
        button.tag = globalTag;
        self.globalTag += 1;
        button.alpha = alpha
        return button
    }
    
    func createLabel(cgRect: CGRect, backgroundColor : UIColor?, textColor: UIColor?, textAlignment: NSTextAlignment?, text: String, alpha : CGFloat) ->UILabel{
        let label: UILabel = UILabel()
        label.frame = cgRect
        if (backgroundColor != nil){
            label.backgroundColor = backgroundColor
        }
        if (textColor != nil){
            label.textColor = textColor
        }
        if (textAlignment != nil){
            label.textAlignment = textAlignment!
        }
        label.text = text
        label.tag = globalTag
        self.globalTag += 1;
        label.alpha = alpha
        return label
    }
    
    func createTextField(cgRect : CGRect, text: String, backgroundColor : UIColor?, textColor: UIColor?, textAlignment: NSTextAlignment?, alpha : CGFloat) ->UITextField{
        let txtField: UITextField = UITextField()
        txtField.frame = cgRect
        if (backgroundColor != nil){
            txtField.backgroundColor = backgroundColor
        }
        if (textColor != nil){
            txtField.textColor = textColor
        }
        if (textAlignment != nil){
            txtField.textAlignment = textAlignment!
        }
        txtField.text = text;
        txtField.tag = globalTag
        self.globalTag += 1;
        txtField.alpha = alpha
        return txtField
    }
    
    func createTextView(cgRect : CGRect, text: String, backgroundColor : UIColor?, textColor: UIColor?, textAlignment: NSTextAlignment?, alpha : CGFloat) ->UITextView{
        let txtView: UITextView = UITextView()
        txtView.frame = cgRect
        if (backgroundColor != nil){
            txtView.backgroundColor = backgroundColor
        }
        if (textColor != nil){
            txtView.textColor = textColor
        }
        if (textAlignment != nil){
            txtView.textAlignment = textAlignment!
        }
        txtView.text = text;
        txtView.tag = globalTag
        self.globalTag += 1;
        txtView.alpha = alpha
        return txtView
    }
    
}
