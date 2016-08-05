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
    override func drawRect(rect: CGRect) {
        
        let separatorLine = UIBezierPath()
        
        separatorLine.moveToPoint(CGPoint(x:rect.maxX, y:rect.minY+(rect.height/3)))
        
        separatorLine.addLineToPoint(CGPoint(x:rect.maxX, y:rect.maxY-(rect.height/4)))
        
        //Keep using the method addLineToPoint until you get to the one where about to close the path
        
        separatorLine.closePath()
        
        //If you want to stroke it with a red color
        UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1).set()
        separatorLine.stroke()
        //If you want to fill it as well
        //separatorLine.fill()
        

    }
}