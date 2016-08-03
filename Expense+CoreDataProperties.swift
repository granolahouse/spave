//
//  Expense+CoreDataProperties.swift
//  spave
//
//  Created by Dominik Faber on 03.08.16.
//  Copyright © 2016 granolahouse. All rights reserved.
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

}
