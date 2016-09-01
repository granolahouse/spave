//
//  CustomProgressRing.swift
//  spave
//
//  Created by Dominik Faber on 10.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit


class CustomProgressRing: UIView {
    
    
    var savingsGoal = 300
    let myLayer = CAShapeLayer()
    let backgroundCircleLayer = CAShapeLayer()
    
    var bezier = UIBezierPath()
    
    var counter: Double = 0 {
        
        didSet {
            if (counter > 0) {
                setProgress(CGFloat(counter)/CGFloat(savingsGoal), duration: 100)
            } else {
                setProgress(0, duration: 100)
            }
            myLayer.strokeColor = UIDesign().blue.CGColor
            myLayer.shadowColor = UIDesign().blue.CGColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.blackColor()
        
        bezier = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2),
                              radius: (self.bounds.width)/2,
                              startAngle: CGFloat(-M_PI_2),
                              endAngle: CGFloat(M_PI * 2 - M_PI_2),
                              clockwise: true)
        
        backgroundCircleLayer.path = bezier.CGPath
        backgroundCircleLayer.fillColor = UIColor.clearColor().CGColor
        backgroundCircleLayer.strokeColor = UIDesign().lightGrey.CGColor
        backgroundCircleLayer.lineWidth = 3.0;
        backgroundCircleLayer.lineCap = kCALineCapRound
        backgroundCircleLayer.strokeStart = 0
        backgroundCircleLayer.strokeEnd = 1
        layer.addSublayer(backgroundCircleLayer)
        
        myLayer.path = bezier.CGPath
        myLayer.fillColor = UIColor.clearColor().CGColor
        myLayer.strokeColor = UIDesign().blue.CGColor
        myLayer.lineWidth = 3.0;
        myLayer.lineCap = kCALineCapRound
        myLayer.strokeStart = 0
        myLayer.strokeEnd = 1
        
        myLayer.shadowColor = UIDesign().blue.CGColor
        myLayer.shadowRadius = 8
        myLayer.shadowOpacity = 1
        
        
        myLayer.shadowOffset = CGSize(width: 0, height: 0)
        
        layer.addSublayer(myLayer)

    }
    override func drawRect(rect: CGRect) {
        bezier = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2),
                              radius: (self.bounds.width)/2,
                              startAngle: CGFloat(-M_PI_2),
                              endAngle: CGFloat(M_PI * 2 - M_PI_2),
                              clockwise: true)
        backgroundCircleLayer.path = bezier.CGPath
        myLayer.path = bezier.CGPath
        
    }
    
    
    
  
    
    func setProgress(progress: CGFloat, duration: CGFloat) {
        
        
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = myLayer.strokeEnd
        animation.toValue = progress
        
        animation.delegate = self
        animation.cumulative = true
        
        
        myLayer.strokeEnd = progress
        myLayer.speed = 0.1
        
        layer.addAnimation(animation, forKey: "strokeEnd")
    }

}