//
//  ExtView.swift
//  DiplNovak
//
//  Created by Novak Second on 25/06/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import UIKit

protocol ExtViewDelegate: class {
    func executeJS(_ buttonId : Int, content : String)
}

class ExtView: UIView {
    
    weak var dataSource: ExtViewDelegate?
    
}
