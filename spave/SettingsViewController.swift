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
    let defaults = UserDefaults.standard

    @IBOutlet weak var stackView: UIStackView!
    var dailyLimit = 0.0
    var numbersOfDaysInCurrentMonth = 0
    var fetchedResultsController : NSFetchedResultsController<Expense>?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetDatabaseButton.isHidden = true
        
        if navigationController != nil {
            goButton.isHidden = true
            resetDatabaseButton.isHidden = false
        }
        
        
        textfieldForSavingsGoal.tag = 1
        textfieldForMonthlyBudget.tag = 2
        
        
        
        updateUI()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.changeDefaultCurrency), name:NSNotification.Name(rawValue: "ChangeDefaultCurrency"), object: nil)

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            stackView.axis = .horizontal
        } else {
            stackView.axis = .vertical
        }
    }
    
    
    
    
    @IBAction func resetDatabase(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to delete all your data? You can't undo this!", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.resetDatabase()
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func go(_ sender: AnyObject) {
        defaults.set(true, forKey: "UserHasSeenOnboarding")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChooseCurrencyViewController
        vc.callBackAction = .changeDefaultCurrency        
    }
    
    func changeDefaultCurrency(_ notification:Notification) {
        
        //Todo: As this function might block the interface we will send it to a background process. Nevertheless we will block the interface until the conversion of currency is done.
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {() -> Void in
         
            
            
       
        
        
        var progress: Float = 0.0
        if let changedCurrency = notification.object as? [String] {
            
            //Show progress bar
            //progressBar.description = "Updating your database"
            
            
            //FIRST: we need to change the defaults
            
            let oldCurrency = Money(amount: 1, currencyIsoString: self.defaults.object(forKey: "usersDefaultCurrency") as! String).currency!
            let newCurrency = Money(amount: 1, currencyIsoString: changedCurrency[0]).currency!
            
            var monthlyBudgetOldCurrency = Money(amount: NSDecimalNumber(value: self.defaults.double(forKey: "monthlyBudget") as Double), currencyIso: oldCurrency)
            var savingsGoalOldCurrency = Money(amount: NSDecimalNumber(value: self.defaults.double(forKey: "savingsGoal") as Double), currencyIso: oldCurrency)
            
            do {
                let monthlyBudgetNewCurrency = try monthlyBudgetOldCurrency.convertMoneyToDifferentCurrency(newCurrency)
                print("monthlyBudgetInNewCurrency: \(monthlyBudgetNewCurrency)")
                self.defaults.set(monthlyBudgetNewCurrency.amount.doubleValue, forKey: "monthlyBudget")
            } catch {
                    //shit
            }
            do {
                let savingsGoalNewCurrency = try savingsGoalOldCurrency.convertMoneyToDifferentCurrency(newCurrency)
                print("savingsGoalNewCurrency: \(savingsGoalNewCurrency)")
                self.defaults.set(savingsGoalNewCurrency.amount.doubleValue, forKey: "savingsGoal")
                
            } catch {
                // shit
            }
            
            
            self.defaults.set(newCurrency.rawValue, forKey: "usersDefaultCurrency")
            
            self.dailyLimit = (self.defaults.double(forKey: "monthlyBudget") - (self.defaults.double(forKey: "savingsGoal")))/Double(self.numbersOfDaysInCurrentMonth)
            
            
            let currencySymbol = Money(amount: 1, currencyIsoString: self.defaults.object(forKey: "usersDefaultCurrency") as! String).currency!.getCurrencySymbol()
            self.labelForCalculatedDailyLimit.text = String("\(currencySymbol)\(self.dailyLimit)")
            
            //SECOND: We now need to change all values in the database to the new currency
            
            //load expenses from Database
            
            // Stack
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            
            //Create Fetch Request
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
            fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            //FetchResultsController
            self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr as! NSFetchRequest<Expense>, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

            
            //convert each expense to the new default currency; Attention, if there is no currency set we assume it's EUR

            do {
                let fetchedExpenses = try self.fetchedResultsController!.managedObjectContext.fetch(fr) as! [Expense]
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
            DispatchQueue.main.async(execute: { () -> Void in
                self.updateUI()
            })
            
        })
        
        
        
    }
    
    func updateUI() {
        
        
        //Numbers of days of current month
        let calendar = Calendar.current
        let currency = Money(amount: 1, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String).currency!
        
        let formatter = NumberFormatter()
        formatter.currencyCode = currency.rawValue
        formatter.numberStyle = .currencyAccounting
        formatter.roundingMode = .halfEven
        formatter.maximumFractionDigits = 0
        
        
        numbersOfDaysInCurrentMonth = (calendar as NSCalendar).component([.day], from: Date().endOfMonth())
        dailyLimit = (defaults.double(forKey: "monthlyBudget") - (defaults.double(forKey: "savingsGoal")))/Double(numbersOfDaysInCurrentMonth)
        textfieldForSavingsGoal.text = formatter.string(from: NSDecimalNumber(value: self.defaults.double(forKey: "savingsGoal") as Double))
        textfieldForMonthlyBudget.text = formatter.string(from: NSDecimalNumber(value: self.defaults.double(forKey: "monthlyBudget") as Double))
        labelForCalculatedDailyLimit.text = formatter.string(from: NSDecimalNumber(value: dailyLimit as Double))
        changeCurrencyButton.setTitle(currency.getCurrencySymbol(), for: UIControlState())
    }
    
}

extension SettingsViewController: UITextFieldDelegate {
    
    //Textfield delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        if textField.text == "" {
            let alert = UIAlertController(title: "Ups", message: "Please enter a valid number", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                    textField.becomeFirstResponder()
            }))
                
                
            self.present(alert, animated: true, completion: nil)
        } else {
        
            
            
            let newMonthlyBudget = Double(textfieldForMonthlyBudget.text!)
            let newSavingsGoal = Double(textfieldForSavingsGoal.text!)
            
            switch textField.tag {
                case 1: defaults.set(newSavingsGoal!, forKey: "savingsGoal")
                case 2: defaults.set(newMonthlyBudget!, forKey: "monthlyBudget")
                default: break
            }
            
           
        
            dailyLimit = (defaults.double(forKey: "monthlyBudget") - (defaults.double(forKey: "savingsGoal")))/Double(numbersOfDaysInCurrentMonth)
            let currencySymbol = Money(amount: 1, currencyIsoString: defaults.object(forKey: "usersDefaultCurrency") as! String).currency!.getCurrencySymbol()

            updateUI()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        switch textField.tag {
            case 1: textfieldForSavingsGoal.text = String(self.defaults.double(forKey: "savingsGoal"))
            case 2: textfieldForMonthlyBudget.text = String(self.defaults.double(forKey: "monthlyBudget"))
            default: break
        }
        
    }
    
    
}
