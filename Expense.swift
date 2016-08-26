//
//  Expense.swift
//  spave
//
//  Created by Dominik Faber on 03.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
//

import Foundation
import CoreData


class Expense: NSManagedObject {

    // Insert code here to add functionality to your managed object subclass
    convenience init(value: NSDecimalNumber, date: NSDate, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Expense", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.value = value
            self.date = date
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
