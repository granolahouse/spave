//
//  CustomAddButton.swift
//  spave
//
//  Created by Dominik Faber on 05.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class CustomAddButton: UIButton {
    
    var path: UIBezierPath?
    


    
    
    
    override func drawRect(rect: CGRect) {
        
        print("Rect with: \(rect.width-10)")
        print("Rect height: \(rect.height-10)")
        
        let rectWithPadding = CGRect(x: rect.minX+5, y: rect.minY+5, width: rect.width-10.0, height: rect.height-10.0)
        
        self.path = UIBezierPath(ovalInRect: rectWithPadding)
        
        self.path!.lineWidth = 3
        
        let lightGrey = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        lightGrey.setStroke()
        self.path!.stroke()
        
        
       
    }
     
    
        
        
    
}