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


class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var changeCurrencyButton: CustomAddButton!
    @IBOutlet weak var textfieldForSavingsGoal: UITextField!
    @IBOutlet weak var textfieldForMonthlyBudget: UITextField!
    @IBOutlet weak var labelForCalculatedDailyLimit: UILabel!
    @IBOutlet weak var goButton: CustomAddButton!
    @IBOutlet weak var resetDatabaseButton: UIButton!
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var stackView: UIStackView!
    var dailyLimit = 0.0
    var numbersOfDaysInCurrentMonth = 0
    var fetchedResultsController : NSFetchedResultsController?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetDatabaseButton.hidden = true
        
        if navigationController != nil {
            goButton.hidden = true
            resetDatabaseButton.hidden = false
        }
        
        
        textfieldForSavingsGoal.tag = 1
        textfieldForMonthlyBudget.tag = 2
        
        
        
        updateUI()
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.changeDefaultCurrency), name:"ChangeDefaultCurrency", object: nil)

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("Landscape")
            stackView.axis = .Horizontal
        } else {
            stackView.axis = .Vertical
        }
    }
    
    
    
    
    @IBAction func resetDatabase(sender: AnyObject) {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.resetDatabase()
    }
    
    
    @IBAction func go(sender: AnyObject) {
        defaults.setBool(true, forKey: "UserHasSeenOnboarding")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! ChooseCurrencyViewController
        vc.callBackAction = .ChangeDefaultCurrency        
    }
    
    func changeDefaultCurrency(notification:NSNotification) {
        
        //Todo: As this function might block the interface we will send it to a background process. Nevertheless we will block the interface until the conversion of currency is done.
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {() -> Void in
         
            
            
       
        
        
        var progress: Float = 0.0
        if let changedCurrency = notification.object as? [String] {
            
            //Show progress bar
            //progressBar.description = "Updating your database"
            
            
            //FIRST: we need to change the defaults
            
            let oldCurrency = Money(amount: 1, currencyIsoString: self.defaults.objectForKey("usersDefaultCurrency") as! String).currency!
            let newCurrency = Money(amount: 1, currencyIsoString: changedCurrency[0]).currency!
            
            var monthlyBudgetOldCurrency = Money(amount: NSDecimalNumber(double: self.defaults.doubleForKey("monthlyBudget")), currencyIso: oldCurrency)
            var savingsGoalOldCurrency = Money(amount: NSDecimalNumber(double: self.defaults.doubleForKey("savingsGoal")), currencyIso: oldCurrency)
            
            do {
                let monthlyBudgetNewCurrency = try monthlyBudgetOldCurrency.convertMoneyToDifferentCurrency(newCurrency)
                print("monthlyBudgetInNewCurrency: \(monthlyBudgetNewCurrency)")
                self.defaults.setDouble(monthlyBudgetNewCurrency.amount.doubleValue, forKey: "monthlyBudget")
            } catch {
                    //shit
            }
            do {
                let savingsGoalNewCurrency = try savingsGoalOldCurrency.convertMoneyToDifferentCurrency(newCurrency)
                print("savingsGoalNewCurrency: \(savingsGoalNewCurrency)")
                self.defaults.setDouble(savingsGoalNewCurrency.amount.doubleValue, forKey: "savingsGoal")
                
            } catch {
                // shit
            }
            
            
            self.defaults.setObject(newCurrency.rawValue, forKey: "usersDefaultCurrency")
            
            self.dailyLimit = (self.defaults.doubleForKey("monthlyBudget") - (self.defaults.doubleForKey("savingsGoal")))/Double(self.numbersOfDaysInCurrentMonth)
            
            
            let currencySymbol = Money(amount: 1, currencyIsoString: self.defaults.objectForKey("usersDefaultCurrency") as! String).currency!.getCurrencySymbol()
            self.labelForCalculatedDailyLimit.text = String("\(currencySymbol)\(self.dailyLimit)")
            
            //SECOND: We now need to change all values in the database to the new currency
            
            //load expenses from Database
            
            // Stack
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let stack = delegate.stack
            
            //Create Fetch Request
            let fr = NSFetchRequest(entityName: "Expense")
            fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            //FetchResultsController
            self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

            
            //convert each expense to the new default currency; Attention, if there is no currency set we assume it's EUR

            do {
                let fetchedExpenses = try self.fetchedResultsController!.managedObjectContext.executeFetchRequest(fr) as! [Expense]
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
                        //self.progressBar.setProgress(progress, animated: true)
                        progress+=1.0
                    } catch {
                        //shit
                    }
                    
                    expense.value = money!.amount
                    let changedCurrency = money!.currency!.rawValue
                    let changedCurrencySymbol = money!.currency!.getCurrencySymbol()
                    expense.currency = changedCurrency
                    

                }
            } catch {
                fatalError("Failed to fetch expenses: \(error)")
            }
            
            //Set the value of the textfields from NSDefaults
            
        }
        
            
            //Update UI on Completion
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateUI()
            })
            
        })
        
        
        
    }
    
    func updateUI() {
        
        
        //Numbers of days of current month
        let calendar = NSCalendar.currentCalendar()
        let currency = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String).currency!
        
        let formatter = NSNumberFormatter()
        formatter.currencyCode = currency.rawValue
        formatter.numberStyle = .CurrencyAccountingStyle
        formatter.roundingMode = .RoundHalfEven
        formatter.maximumFractionDigits = 0
        
        
        numbersOfDaysInCurrentMonth = calendar.component([.Day], fromDate: NSDate().endOfMonth())
        dailyLimit = (defaults.doubleForKey("monthlyBudget") - (defaults.doubleForKey("savingsGoal")))/Double(numbersOfDaysInCurrentMonth)
        textfieldForSavingsGoal.text = formatter.stringFromNumber(NSDecimalNumber(double: self.defaults.doubleForKey("savingsGoal")))
        textfieldForMonthlyBudget.text = formatter.stringFromNumber(NSDecimalNumber(double: self.defaults.doubleForKey("monthlyBudget")))
        labelForCalculatedDailyLimit.text = formatter.stringFromNumber(NSDecimalNumber(double: dailyLimit))
        changeCurrencyButton.setTitle(currency.getCurrencySymbol(), forState: .Normal)
    }
    
}

extension SettingsViewController: UITextFieldDelegate {
    
    //Textfield delegates
    func textFieldDidEndEditing(textField: UITextField) {
       
        if textField.text == "" {
            let alert = UIAlertController(title: "Ups", message: "Please enter a valid number", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                    textField.becomeFirstResponder()
            }))
                
                
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
        
            
            
            let newMonthlyBudget = Double(textfieldForMonthlyBudget.text!)
            let newSavingsGoal = Double(textfieldForSavingsGoal.text!)
            
            switch textField.tag {
                case 1: defaults.setDouble(newSavingsGoal!, forKey: "savingsGoal")
                case 2: defaults.setDouble(newMonthlyBudget!, forKey: "monthlyBudget")
                default: break
            }
            
           
        
            dailyLimit = (defaults.doubleForKey("monthlyBudget") - (defaults.doubleForKey("savingsGoal")))/Double(numbersOfDaysInCurrentMonth)
            let currencySymbol = Money(amount: 1, currencyIsoString: defaults.objectForKey("usersDefaultCurrency") as! String).currency!.getCurrencySymbol()

            updateUI()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        switch textField.tag {
            case 1: textfieldForSavingsGoal.text = String(self.defaults.doubleForKey("savingsGoal"))
            case 2: textfieldForMonthlyBudget.text = String(self.defaults.doubleForKey("monthlyBudget"))
            default: break
        }
        
    }
    
    
}