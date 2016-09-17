//
//  CustomSeperatorLine.swift
//  spave
//
//  Created by Dominik Faber on 05.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class CustomSeperatorLine: UIView {
   
    @IBInspectable var horizontal: Bool = false
    @IBInspectable var color: UIColor = UIColor.black
 
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func draw(_ rect: CGRect) {
        
        if horizontal {
            let separatorLine = UIBezierPath()
            
            separatorLine.move(to: CGPoint(x:rect.minX, y:rect.minY))
            
            separatorLine.addLine(to: CGPoint(x:rect.maxX, y:rect.minY))
            
            //Keep using the method addLineToPoint until you get to the one where about to close the path
            
            separatorLine.close()
            
            //If you want to stroke it with a red color
            color.setStroke()
            
            separatorLine.stroke()
            //If you want to fill it as well
            //separatorLine.fill()
        } else {
            
            let separatorLine = UIBezierPath()
            
            separatorLine.move(to: CGPoint(x:rect.maxX, y:rect.minY))
            
            separatorLine.addLine(to: CGPoint(x:rect.maxX, y:rect.maxY))
            
            //Keep using the method addLineToPoint until you get to the one where about to close the path
            
            separatorLine.close()
            
            //If you want to stroke it with a red color
            color.setStroke()
            
            separatorLine.stroke()
            //If you want to fill it as well
            //separatorLine.fill()
            
        }
        
        

    }
}
