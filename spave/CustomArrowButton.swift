//
//  CustomArrowButton.swift
//  spave
//
//  Created by Dominik Faber on 15.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class CustomArrowButton: UIButton {
    
    @IBInspectable var up: Bool = true
    
    var trianglePathSmallUp: UIBezierPath {
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))     // #1
        trianglePath.addLine(to: CGPoint(x: self.bounds.width/2, y: self.bounds.minY)) // #2
        trianglePath.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY)) // #3
        trianglePath.close()
        return trianglePath
    }
    
    var trianglePathSmallDown: UIBezierPath {
        let trianglePath2 = UIBezierPath()
        trianglePath2.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))     // #1
        trianglePath2.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY)) // #2
        trianglePath2.addLine(to: CGPoint(x: self.bounds.width/2, y: self.bounds.maxY)) // #3
        trianglePath2.close()
        return trianglePath2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func draw(_ rect: CGRect) {
        
        if up {
            
            trianglePathSmallUp.lineWidth = 1
            
            UIDesign().blue.setFill()
            UIDesign().blue.setStroke()
            trianglePathSmallUp.stroke()
            trianglePathSmallUp.fill()
        } else {
            print("do I come here?")
            trianglePathSmallDown.lineWidth = 1
            UIDesign().blue.setFill()
            UIDesign().blue.setStroke()
            trianglePathSmallDown.fill()
            trianglePathSmallDown.stroke()
        }
    }
}
