//
//  CustomAddButton.swift
//  spave
//
//  Created by Dominik Faber on 05.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit



class CustomAddButton: UIButton {
    
    var path: UIBezierPath?
    
    @IBInspectable var strokeColor: UIColor = UIDesign().blue

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func draw(_ rect: CGRect) {
        
        
        let rectWithPadding = CGRect(x: rect.minX+5, y: rect.minY+5, width: rect.width-10.0, height: rect.height-10.0)
        
        self.path = UIBezierPath(ovalIn: rectWithPadding)
        
        self.path!.lineWidth = 3
        
        strokeColor.setStroke()
        self.path!.stroke()
        
        
       
    }
     
    
        
        
    
}
