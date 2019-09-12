//
//  User.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 8/16/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData

class User: NSManagedObject {
    var userflag = false  //user not exists
    func fetchUser(user: String) {
        let context = AppDelegate.viewContext
        let request:NSFetchRequest = User.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", user)
        do {
            let result = try context.fetch(request)
            for item in result {
                if item.userID == user {
                    userflag = true //user exists
                    break
                }
            }
        }catch {
            print(error)
        }
    }

    func deleteUsers(_ user: String,_ context: NSManagedObjectContext) {
        let request:NSFetchRequest = User.fetchRequest()
        do {
            let results = try context.fetch(request)
            print(results.count)

            for item in results{
                if item.value(forKey: "userID") as? String == user || item.value(forKey: "userID") == nil {
                    context.delete(item)
                }
            }
            try context.save()
        }catch {
            print("Could not delete.\(error)")
        }
    }
}
