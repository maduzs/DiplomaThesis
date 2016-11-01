//
//  ExternalViewController.swift
//  DiplNovak
//
//  Created by Novak Second on 25/06/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import UIKit
import WebKit

class ExternalViewController: UIViewController, ExtViewDelegate{

    @IBOutlet weak var extView: ExtView!{
        didSet {
            extView.dataSource = self
        }
    }
    
    // system buttons in view, not from JS
    func executeJS(_ buttonId : Int, content : String){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helper
    func showAlertWithMessage(_ message:String) {
        let alertAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
        }
        
        let alertView:UIAlertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(alertAction)
        
        self.present(alertView, animated: true, completion: { () -> Void in
            
        })
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
}

 
