//
//  SpendingsViewController.swift
//  kaching
//
//  Created by Dominik Faber on 30.07.16.
//  Copyright © 2016 Dominik Faber. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class SpendingsViewController: UITableViewController {
    
  /*  let test:[String] = ["1","2","3"]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return test.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Create the cell
        let cell  = tableView.dequeueReusableCellWithIdentifier("spendingCell", forIndexPath: indexPath)
        
        // Sync notebook -> Cell
        cell.textLabel!.text = test[indexPath.row]
        
        return cell
    }*/
    
    let spending:[Expense] = []
    
    var selectedExpense: Expense?
    let defaults = UserDefaults.standard
    
    var fetchedResultsController : NSFetchedResultsController<Expense>? {
        didSet {
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        
        print("debug")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        super.viewDidLoad()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        
        self.refreshControl?.addTarget(self, action: #selector(SpendingsViewController.refresh), for: UIControlEvents.valueChanged)

        
        // Stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        //Create Fetch Request
        let fr = NSFetchRequest<Expense>(entityName: "Expense")
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        //FetchResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            
        }
        
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedResultsController?.fetchedObjects?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("debug")
        
        let expense = fetchedResultsController!.object(at: indexPath) as! Expense
        
        // Create the cel.
        let cell  = tableView.dequeueReusableCell(withIdentifier: "spendingCell", for: indexPath) as! SpendingsTableViewCell
        var money: Money?
        
        if let currency = expense.currency {
            money = Money(amount: expense.value!, currencyIsoString: currency)
        } else {
            let defaultCurrency = defaults.object(forKey: "usersDefaultCurrency") as! String
            money = Money(amount: expense.value!, currencyIsoString: defaultCurrency)
        }
        
        
        let formatter = NumberFormatter()
        formatter.currencyCode = money!.currency!.rawValue
        formatter.numberStyle = .currencyAccounting
        formatter.maximumFractionDigits = 0
        cell.expense!.text = formatter.string(from: money!.amount)
        
        //Get human readable date 
        
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, h:s a"
        
        let humanReadableExpenseDate = dateFormatter.string(from: expense.date!)
        //dateString now contains the string "Sunday, 7 AM".
        cell.date!.text = humanReadableExpenseDate
        
        
        if let desc = expense.desc {
            cell.desc!.text = desc
        } else {
            cell.desc!.text = ""
        }
        

        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            
            let expense = fetchedResultsController!.object(at: indexPath) as! Expense
            
            // remove your object
            
            print("I will delete \(expense)")
            
            fetchedResultsController?.managedObjectContext.delete(expense)
            //stack.context.deleteObject(expense)
            
            /* save changes
            do {
                try stack.context.save()
                print("saved delete")
            } catch{
                print("error when saving context")
            }*/
            tableView.reloadData()
        }
    }
    
   

    
    
    
    
   
    
    func refresh() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "displayExpense"{
            if let spendingVC = segue.destination as? SpendingViewController {
                spendingVC.expense = fetchedResultsController!.object(at: tableView.indexPathForSelectedRow!) as! Expense
            }
        }
    }

    
    
}

