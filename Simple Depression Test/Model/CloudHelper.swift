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
    
//    static var ckRecords: [CKRecord] = []
    
    static var onCloud = false
    
    static let cloud = CKContainer.default().privateCloudDatabase
    
    class func convertToCkrecord(data: PersonalData, type: String) -> CKRecord {
        let newData = CKRecord(recordType: type)
        newData.setValue(data.scores, forKey: "scores")
        newData.setValue(data.userName, forKey: "userName")
        newData.setValue(data.result, forKey: "result")
        newData.setValue(data.dateTime, forKey: "dateTime")
        newData.setValue(data.totalScore, forKey: "totalScore")
        newData.setValue(data.uuid, forKey: "uuid")
        return newData
    }
    
    class func convertToPersonalData(record: CKRecord) -> PersonalData {
        let username = record.value(forKey: "userName") as? String
        let scores = record.value(forKey: "scores") as? [Int]
        let result = record.value(forKey: "result") as? String
        let totalScore = record.value(forKey: "totalScore") as? Int
        let dateTime = record.value(forKey: "dateTime") as? Date
        let uuid = record.value(forKey: "uuid") as? String
        let newData = PersonalData(userName: username, dateTime: dateTime, scores: scores, totalScore: totalScore, result: result, uuid: uuid)
        return newData
    }

    class func saveData(data: PersonalData, type: String, completion:@escaping (Bool)->Void) {
        let newData = convertToCkrecord(data: data, type: type)
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
    
    // MARK: - methods for batch query from icloud
    class func queryRecords(byname name: String, type: String, complete: @escaping ( [CKRecord]?, Error?)->Void) {

        // Create the initial query
        var predicate = NSPredicate()
        let ckRecords = Array<CKRecord>()
//        var recordIds = Array<CKRecord.ID>()
//        ckRecords.removeAll()
//        recordIDsArray.removeAll()
        if name == "All" {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSPredicate(format: "userName == %@", name)
        }
        let query = CKQuery(recordType: type, predicate: predicate)
        
        // Create the initial query operation
        let queryOperation = CKQueryOperation(query: query)
        
        let operationQueue = OperationQueue()
        queryOperation.resultsLimit = CKQueryOperation.maximumResults
        self.executeQueryOperation(queryOperation, operationQueue, ckRecords) { record, error in
            if let err = error {
                complete(nil, err)
            } else {
                complete(record, nil)
                }
        }


    }
    
    class func executeQueryOperation(_ queryOperation: CKQueryOperation, _ operationQueue: OperationQueue, _ records: [CKRecord], complete: @escaping ( [CKRecord]?, Error?)->Void){
        
        var ckrecords = records
        
        queryOperation.resultsLimit = CKQueryOperation.maximumResults

        // Setup the query operation
        queryOperation.database = CloudHelper.cloud
        
        // Assign a record process handler
        queryOperation.recordFetchedBlock = { (record) in
            // Process each record
            ckrecords.append(record)
//            self.recordIDsArray.append(record.recordID)
        }
        
        // Assign a completion handler
        queryOperation.queryCompletionBlock = { (cursor, error) in
            guard error == nil else {
                // Handle the error
                print(error!)
                complete(nil, error)
                return
            }
            if let queryCursor = cursor {
                let queryCursorOperation = CKQueryOperation(cursor: queryCursor)
                self.executeQueryOperation(queryCursorOperation, operationQueue, ckrecords) { record, error in
                    if record != nil {
                        complete(record, nil)
                    }
                    else {
                        print("continue")
                    }
                }
            } else {
                print("query end. fetch back records:\(ckrecords.count)")
                complete(ckrecords, nil)
            }
            
        }
        // Add the operation to the operation queue to execute it
        operationQueue.addOperation(queryOperation)
    }
    
    // MARK: - query by id
    class func query(byid: String, type: String, complete: @escaping (Bool, Error?)->Void) {
        let predicate = NSPredicate(format: "uuid == %@", byid)
        let query = CKQuery(recordType: type, predicate: predicate)
        cloud.perform(query, inZoneWith: nil) { (records, error) in
            if let err = error {
                complete(false, err)
            }else if let rec = records{
                if rec.count>0{
                    complete(true, nil)
                }else{
                    complete(false, nil)
                }
            }
        }
    }
    
//    class func query(byname name: String, type: String, complete: @escaping (Any?, Error?)->Void) {
//        var results = [PersonalData]()
//        var predicate = NSPredicate()
//        recordIDsArray.removeAll()
//        if name == "All" {
//            predicate = NSPredicate(value: true)
//        } else {
//            predicate = NSPredicate(format: "userName == %@", name)
//        }
//        let query = CKQuery(recordType: type, predicate: predicate)
//
//        cloud.perform(query, inZoneWith: nil) { (records, err) in
//            if err != nil {
//                print(err!)
//                complete(nil, err)
//            } else {
//                print("query successfully")
//                if let records = records {
//                    for item in records {
//                        let username = item.value(forKey: "userName") as? String
//                        let scores = item.value(forKey: "scores") as? [Int]
//                        let result = item.value(forKey: "result") as? String
//                        let totalScore = item.value(forKey: "totalScore") as? Int
//                        let dateTime = item.value(forKey: "dateTime") as? Date
//                        let uuid = item.value(forKey: "uuid") as? String
//                        let newData = PersonalData(userName: username, dateTime: dateTime, scores: scores, totalScore: totalScore, result: result, uuid: uuid)
//                        let recordID = item.recordID
//                        recordIDsArray.append(recordID)
//                        results.append(newData)
//                    }
//                    complete(results, nil)
//                }
//            }
//        }
//    }

    // MARK: - synchronization
    class func syncData(dataType: String, complete: @escaping (Bool)->Void) {

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
        
        
        queryRecords(byname: "All", type: dataType) { records, error in
            if error != nil {
                print(error!)
                complete(false)

            } else {
                print("query finished, \(records?.count ?? 0) records back")
                guard let records = records else {return}

                if records.count > 0{
                    for record in records {
                        let newData = convertToPersonalData(record: record)
                        cloudData.append(newData)
                    }
                }
                //upload
                if localData.count > 0 {
                    var uploadData: Set = Set<PersonalData>(localData)
                    uploadData.subtract(cloudData)
                    var recordsToSave = [CKRecord]()
                    if uploadData.count > 0 {
                        print("upload data amount: \(uploadData.count)")
                        
                        for data in uploadData {
                            let newData = convertToCkrecord(data: data, type: dataType)
                            recordsToSave.append(newData)
                        }
                        let stepper = 400
                        var start = 0
                        
                        for _ in 0...(uploadData.count/stepper) {
                            var end = start + stepper - 1
                            
                            if end > uploadData.count - 1 {
                                end = uploadData.count - 1
                            }
                            let operation = CKModifyRecordsOperation(recordsToSave: Array(recordsToSave[start...end]), recordIDsToDelete: nil)
                            operation.modifyRecordsCompletionBlock = {_,_,err in
                                if err != nil {
                                    complete(false)
                                    print(err!)
                                }else {
                                    print("upload completed")
                                }
                            }
                            cloud.add(operation)
                            start += stepper
                        }
                    }
                }
                    //download
                DispatchQueue.main.async {
                    var downloadData: Set = Set<PersonalData>(cloudData)
                    downloadData.subtract(localData)
                    let dataArray = Array(downloadData)
                    if downloadData.count > 0 {
                        print("download data amount: \(downloadData.count)")
                        
                        switch dataType {
                        case "PHQ9":
                            PHQ9.saveData(data: dataArray) { success in
                                if success {
                                    complete(true)
                                }else {
                                    complete(false)
                                }
                            }
                        case "GAD7":
                            GAD7.saveData(data: dataArray) { success in
                                if success {
                                    complete(true)
                                }else {
                                    complete(false)
                                }
                            }
                        default: break
                        }
                    }
                }
            }
        }
    }
    
    
    class func showAlert(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }
    
    // MARK: - delete all records
    class func deletAll(dataType: String, completion: @escaping (Bool)->Void ) {
        queryRecords(byname: "All", type: dataType) {records,err in
            if err != nil {
                completion(false)
            }
            else {
                var recordIds = [CKRecord.ID]()
                guard let records = records else {return}
                for record in records {
                    recordIds.append(record.recordID)
                }
                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIds)
                operation.completionBlock = {
                    print("delete all")
                    completion(true)
                }
                cloud.add(operation)
            }
        }
    }
    
    // MARK: - delete single record

    class func deleteRecord(data: PersonalData, type: String, complete: @escaping (Bool)->Void) {
        let predicate = NSPredicate(format: "uuid == %@", data.uuid ?? "")
        let query = CKQuery(recordType: type, predicate: predicate)
        cloud.perform(query, inZoneWith: nil) { (record, error) in
            if error == nil{
                guard let recordID = record?.first?.recordID else {return}
                cloud.delete(withRecordID: recordID, completionHandler: { (id, err) in
                    if err == nil {
                        complete(true)
                    } else {
                        complete(false)
                    }
                })
            } else {
                complete(false)
            }
        }
    }
    
    
    
}
