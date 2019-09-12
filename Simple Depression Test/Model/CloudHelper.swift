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

    static let errorMessage = "iCloud sync failed. Please check your iCloud account and connection status."
    static var recordIDsArray: [CKRecord.ID] = []
    
//    static var ckRecords: [CKRecord] = []
    
    static var localUIDs = [String?]()
    
    static var onCloud = false
    
    static let cloud = CKContainer.default().privateCloudDatabase
    
    static var zoneID : CKRecordZone.ID = {
        CKRecordZone(zoneName: "SDT-zone").zoneID
    }()
    
    //MARK: - methods to convert data from PersonalData to CKRecord and vice versa
    class func convertToCkrecord(data: PersonalData, type: String) -> CKRecord {
        let newData = CKRecord(recordType: type, recordID: CKRecord.ID.init(recordName: data.uuid ?? UUID().uuidString, zoneID: zoneID))
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

    //MARK: - save single data on icloud
    class func saveData(data: PersonalData, type: String, completion:@escaping (Bool)->Void) {
        let newData = convertToCkrecord(data: data, type: type)
        cloud.save(newData) { (record, error) in
            
            if error == nil {
                print("Save to iCloud successfully!")
                completion(true)
            } else {
                completion(false)
                print(error!)
//                UIApplication.shared.keyWindow?.rootViewController?.present(showAlert(message: "error!"), animated: true)
            }
        }
    }
    
    // MARK: - methods for batch query from icloud
    class func queryRecords(byname name: String, type: String, complete: @escaping ( [CKRecord]?, Error?)->Void) {

        // Create the initial query
        var predicate = NSPredicate()
        let ckRecords = Array<CKRecord>()

        if name == "All" {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSPredicate(format: "userName == %@", name)
        }
        let query = CKQuery(recordType: type, predicate: predicate)
        
        // Create the initial query operation
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.zoneID = zoneID
        
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
                    if let err = error {
                        complete(record, err)
                    }
                    
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
    
    // MARK: - query by id method
    class func query(byid: String, type: String, complete: @escaping (Bool, Error?)->Void) {
        let predicate = NSPredicate(format: "uuid == %@", byid)
        let query = CKQuery(recordType: type, predicate: predicate)
        cloud.perform(query, inZoneWith: zoneID) { (records, error) in
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
                    if uploadData.count > 0 {
                        print("upload data amount: \(uploadData.count)")
                        
                        self.uploadData(uploadData: Array(uploadData), type: dataType, complete: { (err) in
                            if let error = err {
                                print(error)
                                complete(false)
                            }
                        })
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
                                    print("save PHQ9 successful")
                                }else {
                                    complete(false)
                                }
                            }
                        case "GAD7":
                            GAD7.saveData(data: dataArray) { success in
                                if success {
                                    print("save GAD7 successful")
                                }else {
                                    complete(false)
                                }
                            }
                        default: break
                        }
                    }
                }
                complete(true)
            }
        }
    }
    
    // MARK: - method for upload data by split batch
    class func uploadData(uploadData: [PersonalData], type: String, complete: @escaping (Error?)->Void) {
        var recordsToSave = [CKRecord]()
        for data in uploadData {
            guard let uuid = data.uuid else{return}
            query(byid: uuid, type: type) { (exists, err) in
                if !exists {
                    let newData = convertToCkrecord(data: data, type: type)
                    recordsToSave.append(newData)
                }
            }

        }
        if recordsToSave.count > 0 {
            let stepper = 400
            var start = 0
            
            for _ in 0...(recordsToSave.count/stepper) {
                var end = start + stepper - 1
                
                if end > recordsToSave.count - 1 {
                    end = recordsToSave.count - 1
                }
                let operation = CKModifyRecordsOperation(recordsToSave: Array(recordsToSave[start...end]), recordIDsToDelete: nil)
                operation.modifyRecordsCompletionBlock = {_,_,err in
                    if err != nil {
                        complete(err!)
                        print(err!)
                    }
                }
                cloud.add(operation)
                start += stepper
            }
        }

        print("upload \(recordsToSave.count) records")
        complete(nil)
    }
    
    // MARK: - method to show some info on viewController
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
        cloud.perform(query, inZoneWith: zoneID) { (record, error) in
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
    // MARK: - save custom zone
    // Create a custom zone to contain our note records. We only have to do this once.
    class func createZone(completion: @escaping (Error?) -> Void) {
        let zone = CKRecordZone(zoneName: "SDT-zone")
        zoneID = zone.zoneID
        let recordZone = CKRecordZone(zoneID: self.zoneID)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone], recordZoneIDsToDelete: [])
        operation.modifyRecordZonesCompletionBlock = { _, _, error in
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
        operation.qualityOfService = .userInitiated
        cloud.add(operation)
    }
    
    // MARK: - save subscription on icloud for notification
    // Create the CloudKit subscription we’ll use to receive notification of changes.
    // The SubscriptionID lets us identify when an incoming notification is associated
    // with the query we created.
    static let subscriptionID = "cloudkit-record-changes"
    static let subscriptionSavedKey = "SubscriptionSaved"
    class func saveSubscription(type: String) {
        
        // Use a local flag to avoid saving the subscription more than once.
        let alreadySaved = UserDefaults.standard.bool(forKey: subscriptionSavedKey+type)
        guard !alreadySaved else {
            return
        }
        
        // If you wanted to have a subscription fire only for particular
        // records you can specify a more interesting NSPredicate here.
        // For our purposes we’ll be notified of all changes.
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: type,
                                               predicate: predicate,
                                               subscriptionID: subscriptionID+type,
                                               options: [CKQuerySubscription.Options.firesOnRecordCreation, .firesOnRecordDeletion])
        
        // We set shouldSendContentAvailable to true to indicate we want CloudKit
        // to use silent pushes, which won’t bother the user (and which don’t require
        // user permission.)
        subscription.zoneID = zoneID
//        let subscription = CKRecordZoneSubscription(zoneID: zoneID)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
//        cloud.save(subscription) { (_, err) in
//            if let error = err {
//                print(error.localizedDescription)
//            }
//            UserDefaults.standard.set(true, forKey: self.subscriptionSavedKey+type)
//            print("subscription saved")
//        }
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [])
        operation.modifySubscriptionsCompletionBlock = { (_, _, error) in
            guard error == nil else {
                print(error!)
                return
            }
            print("subscription is successful")
            UserDefaults.standard.set(true, forKey: self.subscriptionSavedKey + type)
        }
        operation.qualityOfService = .userInitiated

        cloud.add(operation)
    }
    
    static let serverChangeTokenKey = "CKServerChangeToken"
    class func handleNotification(reason: CKQueryNotification.Reason, notification: CKQueryNotification) {
        // Use the ChangeToken to fetch only whatever changes have occurred since the last
        // time we asked, since intermediate push notifications might have been dropped.
        var changeToken: CKServerChangeToken? = nil
        let changeTokenData = UserDefaults.standard.data(forKey: serverChangeTokenKey)
        if changeTokenData != nil {
            changeToken = NSKeyedUnarchiver.unarchiveObject(with: changeTokenData!) as? CKServerChangeToken
        }
        let options = CKFetchRecordZoneChangesOperation.ZoneOptions()
        options.previousServerChangeToken = changeToken
        let optionsMap = [zoneID: options]
        let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], optionsByRecordZoneID: optionsMap)
        operation.fetchAllChanges = true
        operation.recordChangedBlock = { record in
            DispatchQueue.main.async {
                let type = record.recordType
                let data = convertToPersonalData(record: record)
                switch reason {
                case .recordCreated:
                    switch type {
                    case "PHQ9": PHQ9.saveData(data: [data], complete: { (success) in
                        if !success {
                            print("save failed")
                        }
                    })
                    case "GAD7": GAD7.saveData(data: [data], complete: { (success) in
                        if !success {
                            print("save failed")
                        }
                    })
                    default:
                        break
                    }
                    
                case .recordDeleted:
                    switch type {
                    case "PHQ9": PHQ9.deleteData(data: [data])
                    case "GAD7": GAD7.deleteData(data: [data])
                    default:
                        break
                    }
                default:
                    break
                }
            }

        }
        operation.recordZoneChangeTokensUpdatedBlock = { zoneID, changeToken, data in
            guard let changeToken = changeToken else {
                return
            }
            
            let changeTokenData = NSKeyedArchiver.archivedData(withRootObject: changeToken)
            UserDefaults.standard.set(changeTokenData, forKey: self.serverChangeTokenKey)
        }
        operation.recordZoneFetchCompletionBlock = { zoneID, changeToken, data, more, error in
            guard error == nil else {
                return
            }
            guard let changeToken = changeToken else {
                return
            }
            
            let changeTokenData = NSKeyedArchiver.archivedData(withRootObject: changeToken)
            UserDefaults.standard.set(changeTokenData, forKey: self.serverChangeTokenKey)
        }
        operation.fetchRecordZoneChangesCompletionBlock = { error in
            guard error == nil else {
                return
            }
        }
        operation.qualityOfService = .userInitiated
        
        cloud.add(operation)
    }
}
