//
//  Onboarding3ViewController.swift
//  spave
//
//  Created by Dominik Faber on 17.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import UIKit

class Onboarding3ViewController: UIViewController {
    
    @IBOutlet weak var textfieldForSavingsGoal: UITextField!
    @IBOutlet weak var textfieldForMonthlyBudget: UITextField!
    @IBOutlet weak var labelForCalculatedDailyLimit: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var dailyLimit = 0
    var numbersOfDaysInCurrentMonth = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the value of the textfields from NSDefaults
        textfieldForSavingsGoal.text = String(defaults.integerForKey("savingsGoal"))
        textfieldForMonthlyBudget.text = String(defaults.integerForKey("monthlyBudget"))
        
        //Numbers of days of current month
        let calendar = NSCalendar.currentCalendar()
        numbersOfDaysInCurrentMonth = calendar.component([.Day], fromDate: NSDate().endOfMonth())
        
        
        dailyLimit = (defaults.integerForKey("monthlyBudget")-defaults.integerForKey("savingsGoal"))/numbersOfDaysInCurrentMonth
        labelForCalculatedDailyLimit.text = String("€\(dailyLimit)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func go(sender: AnyObject) {
        
        defaults.setBool(true, forKey: "UserHasSeenOnboarding")
        var userHasSeen = defaults.boolForKey("UserHasSeenOnboarding")
        print("User has seen: \(userHasSeen)")
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    //Textfield delegates
    func textFieldDidEndEditing(textField: UITextField) {
        
        let newMonthlyBudget = Int(textfieldForMonthlyBudget.text!)
        let newSavingsGoal = Int(textfieldForSavingsGoal.text!)
        defaults.setInteger(newMonthlyBudget!, forKey: "monthlyBudget")
        defaults.setInteger(newSavingsGoal!, forKey: "savingsGoal")
        
        dailyLimit = (defaults.integerForKey("monthlyBudget")-defaults.integerForKey("savingsGoal"))/numbersOfDaysInCurrentMonth
        labelForCalculatedDailyLimit.text = String("€\(dailyLimit)")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}