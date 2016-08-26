//
//  SettingsViewController.swift
//  kaching
//
//  Created by Dominik Faber on 27.07.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var textfieldForSavingsGoal: UITextField!
    @IBOutlet weak var textfieldForMonthlyBudget: UITextField!
    @IBOutlet weak var labelForCalculatedDailyLimit: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()

    var dailyLimit = 0
    var numbersOfDaysInCurrentMonth = 0
    var fetchedResultsController : NSFetchedResultsController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currencySymbol = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String).currency!.getCurrencySymbol()
        //Set the value of the textfields from NSDefaults
        textfieldForSavingsGoal.text = String(defaults.integerForKey("savingsGoal"))
        textfieldForMonthlyBudget.text = String(defaults.integerForKey("monthlyBudget"))
        
        //Numbers of days of current month
        let calendar = NSCalendar.currentCalendar()
        numbersOfDaysInCurrentMonth = calendar.component([.Day], fromDate: NSDate().endOfMonth())
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddExpenseViewController.changeCurrencyToTrack), name:"ChangeCurrencyToTrack", object: nil)
        
        dailyLimit = (defaults.integerForKey("monthlyBudget")-defaults.integerForKey("savingsGoal"))/numbersOfDaysInCurrentMonth
        
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
            
            //load expenses from Database
            
            // Stack
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let stack = delegate.stack
            
            //Create Fetch Request
            let fr = NSFetchRequest(entityName: "Expense")
            fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            //FetchResultsController
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

            
            //convert each expense to the new default currency; Attention, if there is no currency set we assume it's EUR

            do {
                let fetchedExpenses = try fetchedResultsController!.managedObjectContext.executeFetchRequest(fr) as! [Expense]
                for expense in fetchedExpenses {
                    var money: Money?
                        let currentAmount = expense.value!
                    
                        //Attention, if there is no currency set we assume it's EUR, since the only person used the app since now used it in EUR Coco and Me :)
                        if let currentCurrency = expense.currency {
                            money = Money(amount: currentAmount, currencyIsoString: currentCurrency)
                        } else {
                            money = Money(amount: currentAmount, currencyIso: .EUR)
                        }
                    
                    
                    do {
                        money = try money!.convertMoneyToDifferentCurrency(Money(amount: 1, currencyIsoString: changedCurrency[0]).currency!)
                    } catch {
                        //shit
                    }
                    
                    expense.value = money!.amount
                    let changedCurrency = money!.currency!.rawValue
                    let changedCurrencySymbol = money!.currency!.getCurrencySymbol()
                    expense.currency = changedCurrency
                    textfieldForSavingsGoal.text = String(defaults.integerForKey("savingsGoal"))
                    textfieldForMonthlyBudget.text = String(defaults.integerForKey("monthlyBudget"))
                    

                }
            } catch {
                fatalError("Failed to fetch expenses: \(error)")
            }
            
            //Set the value of the textfields from NSDefaults
            
            
            
            
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