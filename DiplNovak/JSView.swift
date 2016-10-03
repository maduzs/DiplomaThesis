//
//  JSView.swift
//  DiplNovak
//
//  Created by Novak Second on 28/02/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import UIKit

protocol DiplViewDelegate: class {
    func executeJS(buttonId : Int, content : String)
}

class JSView: UIView {
    
    weak var dataSource: DiplViewDelegate?
 
    @IBOutlet weak var textView1: UITextView!
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        self.endEditing(true)
    }
    @IBAction func submitButton(sender: UIButton, forEvent event: UIEvent) {
        dataSource?.executeJS(0, content: textView1.text)
    }

}
