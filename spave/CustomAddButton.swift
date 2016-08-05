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
    override func drawRect(rect: CGRect) {
        
        print("Rect with: \(rect.width-10)")
        print("Rect height: \(rect.height-10)")
        
        let rectWithPadding = CGRect(x: rect.minX+5, y: rect.minY+5, width: rect.width-10.0, height: rect.height-10.0)
        
        let path = UIBezierPath(ovalInRect: rectWithPadding)
        
        path.lineWidth = 3
        
        let lightGrey = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        lightGrey.setStroke()
        path.stroke()
        
        
       
    }
}