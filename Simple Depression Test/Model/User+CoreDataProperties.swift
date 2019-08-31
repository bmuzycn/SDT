//
//  User+CoreDataProperties.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/16/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userID: String?
    @NSManaged public var dataStored: NSSet?

}

// MARK: Generated accessors for dataStored
extension User {

    @objc(addDataStoredObject:)
    @NSManaged public func addToDataStored(_ value: DataStored)

    @objc(removeDataStoredObject:)
    @NSManaged public func removeFromDataStored(_ value: DataStored)

    @objc(addDataStored:)
    @NSManaged public func addToDataStored(_ values: NSSet)

    @objc(removeDataStored:)
    @NSManaged public func removeFromDataStored(_ values: NSSet)

}
