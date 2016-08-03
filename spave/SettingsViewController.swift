//
//  SettingsViewController.swift
//  kaching
//
//  Created by Dominik Faber on 27.07.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var textfieldForSavingsGoal: UITextField!
    @IBOutlet weak var textfieldForMonthlyBudget: UITextField!
    
    let defaults = NSUserDefaults.standardUserDefaults()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the value of the textfields from NSDefaults
        textfieldForSavingsGoal.text = String(defaults.integerForKey("savingsGoal"))
        textfieldForMonthlyBudget.text = String(defaults.integerForKey("monthlyBudget"))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveSettings(sender: AnyObject) {
        
        let newMonthlyBudget = Int(textfieldForMonthlyBudget.text!)
        let newSavingsGoal = Int(textfieldForSavingsGoal.text!)
        defaults.setInteger(newMonthlyBudget!, forKey: "monthlyBudget")
        defaults.setInteger(newSavingsGoal!, forKey: "savingsGoal")
    }
    
    @IBAction func resetDatabase(sender: AnyObject) {
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.resetDatabase()
    }
}