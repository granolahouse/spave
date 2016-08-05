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


class SpendingsViewController: CoreDataTableViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .SingleLine
        tableView.separatorColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        
        self.refreshControl?.addTarget(self, action: #selector(SpendingsViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)

        
        // Stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        //Create Fetch Request
        let fr = NSFetchRequest(entityName: "Expense")
        fr.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        //FetchResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let expense = fetchedResultsController!.objectAtIndexPath(indexPath) as! Expense
        
        // Create the cell
        let cell  = tableView.dequeueReusableCellWithIdentifier("spendingCell", forIndexPath: indexPath)
        
        // Sync notebook -> Cell
        cell.textLabel!.text = String("€\(expense.value!)")
        
        //Get human readable date 
        
       
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, h:s a"
        
        let humanReadableExpenseDate = dateFormatter.stringFromDate(expense.date!)
        //dateString now contains the string "Sunday, 7 AM".
        cell.detailTextLabel!.text = humanReadableExpenseDate
        
        

        return cell
        
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            // Stack
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let stack = delegate.stack
            
            let expense = fetchedResultsController!.objectAtIndexPath(indexPath) as! Expense
            
            // remove your object
            
            stack.context.deleteObject(expense)
            
            // save changes
            do {
                try stack.context.save()
            } catch{
                print("error when saving context")
            }
            tableView.reloadData()
        }
    }
    
   

    
    
    
    
   
    
    func refresh() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "displayExpense"{
            if let spendingVC = segue.destinationViewController as? SpendingViewController {
                spendingVC.expense = fetchedResultsController!.objectAtIndexPath(tableView.indexPathForSelectedRow!) as! Expense
            }
        }
    }

    
    
}

