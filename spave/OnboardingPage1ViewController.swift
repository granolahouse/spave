//
//  OnboardingPage1ViewController.swift
//  spave
//
//  Created by Dominik Faber on 29.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit

class OnboardingPage1ViewController: UIViewController {
    @IBOutlet weak var progressRing: CustomProgressRing!
    
    override func viewDidLoad() {
        progressRing.backgroundColor = UIColor.clearColor()
        
        progressRing.savingsGoal = 100
        progressRing.counter = 0
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.progressRing.setProgress(0.75, duration: 100000)
        }
    }
    override func viewDidAppear(animated: Bool) {
        
        
    }
}