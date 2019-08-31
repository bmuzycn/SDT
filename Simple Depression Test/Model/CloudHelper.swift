//
//  CloudHelper.swift
//  Simple Depression Test
//
//  Created by Tim on 8/30/19.
//  Copyright © 2019 Yu Zhang. All rights reserved.
//

import UIKit
import CloudKit

class CloudHelper {

    static let errorMessage = "iCloud connection failed. Please check your device account and wireless connection."
    static var recordIDsArray: [CKRecord.ID] = []
    
    static var onCloud = false
    
    class func saveData(data: PersonalData, type: String, completion:@escaping (Bool)->Void) {
        let cloud = CKContainer.default().privateCloudDatabase
        let newData = CKRecord(recordType: type)
        newData.setValue(data.scores, forKey: "scores")
        newData.setValue(data.userName, forKey: "userName")
        newData.setValue(data.result, forKey: "result")
        newData.setValue(data.dateTime, forKey: "dateTime")
        newData.setValue(data.totalScore, forKey: "totalScore")
        cloud.save(newData) { (record, error) in
            
            if error == nil {
                print("Save to iCloud successfully!")
                completion(true)
            } else {
                completion(false)
                print(error!)
            }
        }
    }
    
    class func query(byname name: String, type: String, complete: @escaping (Any?, Error?)->Void) {
        var results = [PersonalData]()
        var predicate = NSPredicate()
        if name == "All" {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSPredicate(format: "userName == %@", name)
        }
        let query = CKQuery(recordType: type, predicate: predicate)
        let cloud = CKContainer.default().privateCloudDatabase
        
        cloud.perform(query, inZoneWith: nil) { (records, err) in
            if err != nil {
                print(err!)
                complete(nil, err)
            } else {
                print("query successfully")
                if let records = records {
                    for item in records {
                        let username = item.value(forKey: "userName") as? String
                        let scores = item.value(forKey: "scores") as? [Int]
                        let result = item.value(forKey: "result") as? String
                        let totalScore = item.value(forKey: "totalScore") as? Int
                        let dateTime = item.value(forKey: "dateTime") as? Date
                        let newData = PersonalData(userName: username, dateTime: dateTime, scores: scores, totalScore: totalScore, result: result)
                        let recordID = item.recordID
                        recordIDsArray.append(recordID)
                        results.append(newData)
                    }
                    complete(results, nil)
                }
            }
        }
    }

    
    class func syncData(dataType: String, complete: @escaping (Bool)->Void) {
        let cloud: CKDatabase = CKContainer.default().privateCloudDatabase
        var cloudData = [PersonalData]()
        var localData = [PersonalData]()
        switch dataType {
            case "PHQ9":
                localData = PHQ9.fetchAll() as! [PersonalData]
            case "GAD7":
                localData = GAD7.fetchAll() as! [PersonalData]
            default:
                break
        }
        query(byname: "All", type: dataType) { (result, err) in
            if err != nil {
                print(err!)
                complete(false)
            } else {
                cloudData = result as! [PersonalData]

                var uploadData: Set = Set<PersonalData>(localData)
                uploadData.subtract(cloudData)
                var recordsToSave = [CKRecord]()
                if uploadData.count > 0 {
                    for data in uploadData {
                        let newData = CKRecord(recordType: dataType)
                        newData.setValue(data.dateTime, forKey: "dateTime")
                        newData.setValue(data.userName, forKey: "userName")
                        newData.setValue(data.scores, forKey: "scores")
                        newData.setValue(data.totalScore, forKey: "totalScore")
                        newData.setValue(data.result, forKey: "result")
                        recordsToSave.append(newData)
                    }
                    
                    let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
                    operation.modifyRecordsCompletionBlock = {_,_,err in
                        if err != nil {
                            complete(false)
                            print(err!)
                        }else {
                            print("upload completed")
                        }
                    }
                    cloud.add(operation)
                }

                var downloadData: Set = Set<PersonalData>(cloudData)
                downloadData.subtract(localData)
                if downloadData.count > 0 {
                    for data in downloadData {
                        switch dataType {
                        case "PHQ9":
                            PHQ9.saveData(data.totalScore, data.scores, data.result, data.userName, data.dateTime)
                        case "GAD7":
                            GAD7.saveData(data.totalScore, data.scores, data.result, data.userName, data.dateTime)
                        default: break
                        }
                    }
                }
                complete(true)

            }
          }
        }
    
    class func showAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
    
    
    class func deletAll(dataType: String, completion: @escaping (Bool)->Void ) {
        let cloud: CKDatabase = CKContainer.default().privateCloudDatabase
        query(byname: "All", type: dataType) {records,err in
            if err != nil {
                completion(false)
            }
            else {
                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsArray)
                operation.completionBlock = {
                    print("delete all")
                    completion(true)
                }
                
                cloud.add(operation)
            }
        }

        
    }
}
