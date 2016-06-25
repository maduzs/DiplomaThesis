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
    
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var textView1: UITextView!
    
    @IBAction func buttonRun(sender: UIButton, forEvent event: UIEvent) {
        var i = 0;
        while i < 1{
            i++;
            dataSource?.executeJS(4, content: textView1.text)
        }
    }
    @IBAction func buttonA(sender: UIButton, forEvent event: UIEvent) {
        dataSource?.executeJS(3, content: "")
    }
    @IBAction func buttonX(sender: UIButton, forEvent event: UIEvent) {
        var i = 0;
        while i < 1{
            i++;
            dataSource?.executeJS(1, content: "")
        }
    }
    @IBAction func buttonY(sender: UIButton, forEvent event: UIEvent) {
        dataSource?.executeJS(1, content: "")
    }
    @IBAction func buttonZ(sender: UIButton, forEvent event: UIEvent) {
        dataSource?.executeJS(2, content: "")
    }
    
    @IBAction func button1(sender: UIButton, forEvent event: UIEvent) {
        dataSource?.executeJS(5, content: textView1.text)
    }
    @IBAction func button2(sender: UIButton, forEvent event: UIEvent) {
        dataSource?.executeJS(6, content: textView1.text)
    }
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        self.endEditing(true)
    }
    
    var lineWidth : CGFloat = 3 {
        didSet {
            setNeedsDisplay() 
        }
    }
    var color : UIColor = UIColor.blueColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var scale : CGFloat = 0.9 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var faceCenter : CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    var faceRadius : CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }

    // test for drawing
    override func drawRect(rect: CGRect) {
        /*let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        facePath.lineWidth = lineWidth
        color.set()
        facePath.stroke()*/
    }


}
