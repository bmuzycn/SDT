//
//  AppDelegate.swift
//  Simple Depression Test
//
//  Created by Yu Zhang on 4/21/18.
//  Copyright © 2018 Yu Zhang. All rights reserved.
//

import UIKit
import CoreData
//import Firebase
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Register with APNs
        application.registerForRemoteNotifications()
        buildKeyWindow()
        Localizer.DoTheMagic()
//        FirebaseApp.configure()
        return true
    }

    private func buildKeyWindow() {
        window = UIWindow()
        window!.makeKeyAndVisible()
        let isFristOpen = UserDefaults.standard.object(forKey: "isFristOpenApp")
        if isFristOpen == nil {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let gv = GuideViewController(collectionViewLayout: layout)
            window?.rootViewController = gv
            UserDefaults.standard.set("isFristOpenApp", forKey: "isFristOpenApp")
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let firstViewController =  storyboard.instantiateViewController(withIdentifier: "TabViewController")
            window?.rootViewController = firstViewController
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
    }


    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Push notification received: \(userInfo)")
        guard let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {return}
        if ((ckNotification.subscriptionID?.contains(find: CloudHelper.subscriptionID)) ?? false )  {
            let reason = (ckNotification as! CKQueryNotification).queryNotificationReason
            CloudHelper.handleNotification(reason: reason, notification: ckNotification as! CKQueryNotification)

    }
    
//    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        print("Push notification received: \(userInfo)")
//
////        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "recordsDidChangeRemotely"), object: nil, userInfo: userInfo)
//        guard let ckNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) else {return}
//        if (ckNotification.subscriptionID! == CloudHelper.subscriptionID)  {
//            let reason = (ckNotification as! CKQueryNotification).queryNotificationReason
//            CloudHelper.handleNotification(reason: reason, notification: ckNotification as! CKQueryNotification)
//            completionHandler(.newData)
//        } else {
//            completionHandler(.noData)
//        }
//
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Simple_Depression_Test")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print("Unresolved error \(error), \(error.userInfo)")
                self.window?.rootViewController?.present(CloudHelper.showAlert(message: "Unresolved error: \(error.userInfo)"), animated: true)
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    static var persistentContainer: NSPersistentContainer {
        return ((UIApplication.shared.delegate as! AppDelegate).persistentContainer)
    }
    
    static var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                self.window?.rootViewController?.present(CloudHelper.showAlert(message: "Unresolved error:\(nserror.userInfo)"), animated: true)
            }
        }
    }
    
    //custom func
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func getDocDir() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }

}

