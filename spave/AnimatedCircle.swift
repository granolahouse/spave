//
//  drawArc.swift
//  kaching
//
//  Created by Dominik Faber on 07.07.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class AnimatedCircle: UIView {
    
    var savingsGoal = 300
    let circleLayer: CAShapeLayer = CAShapeLayer()
    
    
    @IBInspectable var counter: Int = 0 {
        didSet {
            
            //the view needs to be refreshed
            setNeedsDisplay()
            animateCircle()
            
        }
    }
    @IBInspectable var counterColor: UIColor = UIColor.orangeColor()
    @IBInspectable var counterInnerColor: UIColor = UIColor.greenColor()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    func animateCircle() {
    
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = max(bounds.width, bounds.height)-40
        print("Width:\(bounds.width), height: \(bounds.height), radius: \(radius)")
        let arcWidth: CGFloat = 3
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
        
    
        // Create the pathes
        var path = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0),
                                radius: (self.frame.size.width - 10)/2,
                                startAngle: 3*π/2,
                                endAngle: 2*π,
                                clockwise: clockWise)
        

        
        
        var pathInner = UIBezierPath(arcCenter: center,
                                     radius: radius/2 - arcWidth/2-5,
                                     startAngle: startAngle,
                                     endAngle: startAngle-0.01,
                                     clockwise: true)
        
        /*pathInner.lineWidth = arcWidth
        
        let lightGrey = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        lightGrey.setStroke()
        pathInner.stroke()*/
        
        
    
        
        
        //Animation stuff
        
        circleLayer.path = path.CGPath
        circleLayer.fillColor = UIColor.clearColor().CGColor
        circleLayer.strokeColor = UIColor.redColor().CGColor
        circleLayer.lineWidth = 3.0;
        circleLayer.lineCap = kCALineCapRound
        
        
        
        // Add the circleLayer to the view's layer's sublayers
        layer.addSublayer(circleLayer)
        
        layer.rasterizationScale = 2 * UIScreen.mainScreen().scale
        layer.shouldRasterize = true
        
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = 1
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 1
        
        circleLayer.shadowColor = UIColor.redColor().CGColor
        circleLayer.shadowRadius = 20
        circleLayer.shadowOpacity = 0.7
        circleLayer.shadowOffset = CGSize(width: 0, height: 0)
        
        //circleLayer.lineCap = "kCALineCapRound"
        
        animation.toValue = circleLayer.strokeEnd
        
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Do the actual animation
        circleLayer.addAnimation(animation, forKey: "animateCircle")
        
        
        
        
        
        
        
        
        
        
        
    }
    
  
    
}
