//
//  DataStored+CoreDataProperties.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/16/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//
//

import Foundation
import CoreData


extension DataStored {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataStored> {
        return NSFetchRequest<DataStored>(entityName: "DataStored")
    }

    @NSManaged public var dateTime: NSDate?
    @NSManaged public var result: NSObject?
    @NSManaged public var scores: NSObject?
    @NSManaged public var user: User?

}
