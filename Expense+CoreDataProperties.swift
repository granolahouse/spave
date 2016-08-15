//
//  Expense+CoreDataProperties.swift
//  
//
//  Created by Dominik Faber on 15.08.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Expense {

    @NSManaged var date: NSDate?
    @NSManaged var location: NSObject?
    @NSManaged var value: NSNumber?
    @NSManaged var desc: String?

}
