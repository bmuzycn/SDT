//
//  Gad7.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 1/22/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//


import UIKit
import CoreData

class GAD7: NSManagedObject {
    static var scoresArray = [[Int]]()
    static var resultArray = [String]()
    static var dateArray = [String]()
    static var totalArray = [Int]()
    static var flag = Bool() //to see if the data size >fetchLimit
    static var count = Int()
    static let context = AppDelegate.viewContext

    class func saveData(_ totalScore: Int?, _ scores: [Int]?,_ result: String?,_ user: String?, _ date: Date?, _ uuid: String?){
        //check exist data
        let fetchRequest:NSFetchRequest = GAD7.fetchRequest()
        if let uid = uuid {
            fetchRequest.predicate = NSPredicate(format: "uuid == %@", uid)
            do {
                let fetchresult = try context.fetch(fetchRequest)
                if fetchresult.count > 0 {
                    print("Save failed due to record exists")
                } else {
                    //save data
                    let request:NSFetchRequest = User.fetchRequest()
                    request.predicate = NSPredicate(format: "userID == %@", user ?? "")
                    var existUser: User?
                    
                    do {
                        let result = try context.fetch(request)
                        for item in result {
                            if item.userID == user {
                                existUser = item
                                break
                            }
                        }
                    }catch {
                        print(error)
                    }
                    
                    let newData = GAD7(context: context)
                    newData.totalScore = Int16(totalScore ?? 0)
                    newData.scores = scores
                    newData.result = result
                    newData.userName = user
                    newData.dateTime = date
                    newData.uuid = uuid
                    if existUser == nil {
                        existUser = User(context: context)
                        existUser?.userID = user //assign existUser a new userID
                    }
                    newData.user = existUser
                    
                    do {
                        try context.save()
                        print("save successively")
                    }catch {
                        print(error)
                    }
                }
            }catch {
                   print(error)
                }
        }
    }
    //return last fetchLimit records
    class func fetchData(_ user: String,_ n: Int ) {
        clearData()
        let request = NSFetchRequest<GAD7>(entityName: "GAD7")
        request.predicate = NSPredicate(format: "userName = %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "dateTime", ascending: true)]
        var startNum = 0
        var endNum = 0
        do {
            let data = try context.fetch(request)
            self.count = data.count
            if self.count != 0 {
                if data.count - Settings.fetchLimit*n == 0 {
                    startNum = 0
                    endNum = Settings.fetchLimit - 1
                    flag = false
                }
                else if (data.count - Settings.fetchLimit*n) > 0 && (data.count - Settings.fetchLimit*n) <= Settings.fetchLimit  {
                    startNum = 0
                    endNum = data.count - Settings.fetchLimit*n - 1
                    flag = false
                }else if (data.count - Settings.fetchLimit*n) > Settings.fetchLimit {
                    startNum = data.count - Settings.fetchLimit*(n+1)
                    endNum = data.count - Settings.fetchLimit*n - 1
                    flag = true
                }
                else {
                    // pageUp is not allowed
                    flag = false
                }
                for index in startNum...endNum{
                    let item = data[index]
                    resultArray.append(item.value(forKey: "result")! as! String)
                    let date = item.value(forKey: "dateTime")
                    let formatter = DateFormatter()
                    formatter.dateFormat = "M/dd/yy"
                    let strDate = formatter.string(from: date as! Date)
                    dateArray.append(strDate)
                    scoresArray.append(item.value(forKey: "scores") as! [Int])
                    totalArray.append(item.value(forKey: "totalScore") as! Int)
                }
            } else {
                print("data is empty!")
                flag = false
                
            }
            
        }
        catch let error as NSError {
            // something went wrong, print the error.
            print(error.description)
        }
    }
    
    class func saveData(data: [PersonalData], complete: (Bool)->Void) {

        for personalData in data {
            //check if data exists
            let requestForData:NSFetchRequest = GAD7.fetchRequest()
            guard let uuid = personalData.uuid else {return}
            requestForData.predicate = NSPredicate(format: "uuid == %@", uuid)
            do {
                let result = try context.fetch(requestForData)
                if result.count > 0 {
                    continue
                }
            }catch {
                print(error)
            }
            //check if user already exists
            let request:NSFetchRequest = User.fetchRequest()
            request.predicate = NSPredicate(format: "userID == %@", personalData.userName ?? "")
            var existUser: User?
            do {
                let fetchresult = try context.fetch(request)
                if fetchresult.count > 0 {
                    existUser = fetchresult.first
                }
                
            }catch {
                print(error)
                complete(false)
            }
            let newData = GAD7(context: context)
            newData.totalScore = Int16(personalData.totalScore ?? 0)
            newData.scores = personalData.scores
            newData.result = personalData.result
            newData.userName = personalData.userName
            newData.dateTime = personalData.dateTime
            newData.uuid = personalData.uuid
            if existUser == nil {
                existUser = User(context: context)
                existUser?.userID = personalData.userName //assign existUser a new userID
            }
            newData.user = existUser
        }
        do {
            try context.save()
        } catch {
            print(error)
            complete(false)
        }
        context.reset()
        complete(true)

    }
    
    class func deleteData(data: [PersonalData]) {
        var uuids = [String]()
        for data in data {
            uuids.append(data.uuid ?? "")
        }
        let request = NSFetchRequest<GAD7>(entityName: "GAD7")
        request.predicate = NSPredicate(format: "ANY uuid IN %@", uuids)
        do {
            let results = try context.fetch(request)
            
            for data in results {
                context.delete(data)
                
            }
            try context.save()
            
        } catch {
            print("Could not delete.\(error)")
        }
    }
    
    class func deleteData(_ user: String, _ n: Int, _ x: Int) {
        let request = NSFetchRequest<GAD7>(entityName: "GAD7")
        request.predicate = NSPredicate(format: "userName = %@", user)
        do {
            let data = try context.fetch(request)
            if data.count == 0 {
                self.count = 0
            } else if data.count - Settings.fetchLimit*n < Settings.fetchLimit {
                print("data\(x) will be deleted")
                context.delete(data[x])
            }else {
                print("data\(data.count-Settings.fetchLimit*(n+1)+x) will be deleted")
                
                context.delete(data[data.count-Settings.fetchLimit*(n+1)+x])
            }
            try context.save()
            
        } catch {
            print("Could not delete.\(error)")
        }
    }
    
    class func fetchAll(_ userName: String? = nil) -> Any? {
        var results = [PersonalData]()
        let request = NSFetchRequest<GAD7>(entityName: "GAD7")
        let sortbyName = NSSortDescriptor(key: "userName", ascending: true)
        let sortbyTime = NSSortDescriptor(key: "dateTime", ascending: true)
        request.sortDescriptors = [sortbyName, sortbyTime]
        
        if let userName = userName {
            request.predicate = NSPredicate(format: "userName == %@", userName)
            
        }
        do {
            let data = try context.fetch(request)
            if data.count > 0 {
                for item in data {
                    if item.uuid == nil {
                        item.uuid = UUID().uuidString
                    }
                    let personalData = PersonalData(userName: item.userName, dateTime: item.dateTime, scores: item.scores, totalScore: Int(item.totalScore), result: item.result, uuid: item.uuid)
                    results.append(personalData)
                }
                try context.save()
            }
            
        } catch {
            print(error)
        }
        context.reset()
        return results
        
    }
    
    class func clearData() {
        scoresArray = []
        totalArray = []
        dateArray = []
        resultArray = []
    }
}



