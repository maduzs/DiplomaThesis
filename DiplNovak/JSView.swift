//
//  JSView.swift
//  DiplNovak
//
//  Created by Novak Second on 28/02/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import UIKit

protocol DiplViewDelegate: class {
    func execute(_ buttonId : Int,content : String)
}

class JSView: UIView {
    
    weak var dataSource: DiplViewDelegate?
 
    @IBOutlet weak var textView1: UITextView!
    
    @IBOutlet weak var debugTextView: UITextView!
    
    @IBOutlet weak var consoleButton: UIButton!
    
    @IBAction func userTappedBackground(_ sender: AnyObject) {
        self.endEditing(true)
    }
    @IBAction func submitButton(_ sender: UIButton, forEvent event: UIEvent){
        dataSource?.execute(0, content: textView1.text)
    }
    
    @IBAction func clearButtonAction(_ sender: UIButton, forEvent event: UIEvent) {
        dataSource?.execute(1, content: "")
    }
    
    @IBAction func consoleButtonAction(_ sender: UIButton, forEvent event: UIEvent) {
        dataSource?.execute(2, content: "")
    }
    
}
