//
//  drawArc.swift
//  kaching
//
//  Created by Dominik Faber on 07.07.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import Foundation
import UIKit

let π:CGFloat = CGFloat(M_PI)

@IBDesignable class CounterView: UIView {
    
    var savingsGoal = 300

    
    @IBInspectable var counter: Int = 0 {
        didSet {
            
                //the view needs to be refreshed
                setNeedsDisplay()
            
        }
    }
    @IBInspectable var counterColor: UIColor = UIColor.orangeColor()
    @IBInspectable var counterInnerColor: UIColor = UIColor.greenColor()

    
    override func drawRect(rect: CGRect) {
        // 1
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        
        // 2
        let radius: CGFloat = max(bounds.width, bounds.height)
        print("Width:\(bounds.width), height: \(bounds.height), radius: \(radius)")
        // 3
        let arcWidth: CGFloat = 6
        
        // 4
        let startAngle: CGFloat = 3 * π / 2
        
        //1 - first calculate the difference between the two angles
        //ensuring it is positive
        let angleDifference: CGFloat = 2 * π
        
        //then calculate the arc for each single glass
        let arcLengthPerGlass = angleDifference / CGFloat(savingsGoal)
        
        var endAngle: CGFloat = arcLengthPerGlass * CGFloat(counter) + startAngle
        var clockWise: Bool = true
        
        if (counter <= 0) {
            clockWise = false
        } else {
            clockWise = true
        }
        // 5
        var path = UIBezierPath(arcCenter: center,
                                radius: radius/2 - arcWidth/2-5,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: clockWise)
        
        var pathInner = UIBezierPath(arcCenter: center,
                                radius: radius/2 - arcWidth/2-5,
                                startAngle: startAngle,
                                endAngle: startAngle-0.01,
                                clockwise: true)
        
        pathInner.lineWidth = arcWidth
        
        let lightGrey = UIColor(red: 255/155, green: 255/155, blue: 255/155, alpha: 0.5)
        lightGrey.setStroke()
        pathInner.stroke()

        
        // 6
        path.lineWidth = arcWidth
        counterColor.setStroke()
        path.lineCapStyle = .Round
        path.stroke()
        
        
        
    }
    
}
