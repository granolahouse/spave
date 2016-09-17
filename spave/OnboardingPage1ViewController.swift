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
        progressRing.backgroundColor = UIColor.clear
        
        progressRing.savingsGoal = 100
        progressRing.counter = 0
        //Todo
        let time = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.progressRing.setProgress(0.75, duration: 100000)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
}
