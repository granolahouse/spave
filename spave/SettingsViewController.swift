//
//  SettingsViewController.swift
//  kaching
//
//  Created by Dominik Faber on 27.07.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddExpenseViewController.changeCurrencyToTrack), name:"ChangeCurrencyToTrack", object: nil)
        
        dailyLimit = (defaults.integerForKey("monthlyBudget")-defaults.integerForKey("savingsGoal"))/numbersOfDaysInCurrentMonth
        let currencySymbol = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String).currency!.getCurrencySymbol()
        labelForCalculatedDailyLimit.text = String("\(currencySymbol)\(dailyLimit)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func resetDatabase(sender: AnyObject) {
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.resetDatabase()
    }
    
    func changeCurrencyToTrack(notification:NSNotification) {
        if let changedCurrency = notification.object as? [String] {
            defaults.setObject(changedCurrency[0], forKey: "usersDefaultCurrency")
            let currencySymbol = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String).currency!.getCurrencySymbol()
            labelForCalculatedDailyLimit.text = String("\(currencySymbol)\(dailyLimit)")
            
            //TODO: We now need to change all values in the database to the new currency
            
            
            
        }
        
    }
    
    
    
    //Textfield delegates
    func textFieldDidEndEditing(textField: UITextField) {
       
        if textField.text == "" {
            let alert = UIAlertController(title: "Ups", message: "Please enter a valid number", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                    textField.becomeFirstResponder()
            }))
                
                
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
        
            let newMonthlyBudget = Int(textfieldForMonthlyBudget.text!)
            let newSavingsGoal = Int(textfieldForSavingsGoal.text!)
            defaults.setInteger(newMonthlyBudget!, forKey: "monthlyBudget")
            defaults.setInteger(newSavingsGoal!, forKey: "savingsGoal")
        
            dailyLimit = (defaults.integerForKey("monthlyBudget")-defaults.integerForKey("savingsGoal"))/numbersOfDaysInCurrentMonth
            let currencySymbol = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String).currency!.getCurrencySymbol()
            
            labelForCalculatedDailyLimit.text = String("\(currencySymbol)\(dailyLimit)")
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}