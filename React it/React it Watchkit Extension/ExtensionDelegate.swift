//
//  ExtensionDelegate.swift
//  React it Watchkit Extension
//
//  Created by Marco Cruz on 27/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import WatchConnectivity
import HealthKit
import UserNotifications

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate , HKWorkoutSessionDelegate, UNUserNotificationCenterDelegate{
    
    var session : WCSession!
    let healthStore = HKHealthStore()
    var workoutActive = false
    var workoutSession : HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    var currenQuery : HKQuery?
    var heartrateValues = [[Int]]()

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let controller = WKExtension.shared().rootInterfaceController as? InterfaceController {
            // Call to a custom method in the root interface controller to handle the notification
            controller.handleAction(notification: response.notification)
            completionHandler()
        }
    }
    
    func startHeartMonitoring(){
        guard HKHealthStore.isHealthDataAvailable() == true else {
            print("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            print("not allowed")
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
            if success == false {
                print("not allowed")
            }
        }
        self.workoutActive = true
        startWorkout()
    }
    
    func stopHeartMonitoring(){
        if let workout = self.workoutSession {
            self.healthStore.end(workout)
            
            //send message to phone with heartrate data
            let message = ["heartrate":self.heartrateValues]
            print(message)
            self.session.sendMessage(message, replyHandler: nil, errorHandler: {
                error in print(error.localizedDescription)
            })
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Do nothing for now
        print("Workout error")
    }
    
    
    func workoutDidStart(_ date : Date) {
        if let query = createHeartRateStreamingQuery(date) {
            self.currenQuery = query
            healthStore.execute(query)
        } else {
            //cannot start
        }
    }
    
    func workoutDidEnd(_ date : Date) {
        healthStore.stop(self.currenQuery!)
        workoutSession = nil
    }

    
    func startWorkout() {
        
        if (workoutSession != nil) {
            return
        }
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .crossTraining
        workoutConfiguration.locationType = .indoor
        
        do {
            workoutSession = try HKWorkoutSession(configuration: workoutConfiguration)
            workoutSession?.delegate = self
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        healthStore.start(self.workoutSession!)
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func updateHeartRate(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else{return}
            let value = sample.quantity.doubleValue(for: self.heartRateUnit)
            
            let interfaceController = WKExtension.shared().rootInterfaceController as? InterfaceController
            print("time: \(interfaceController?.videoGameTime), \(UInt16(value))")
            
            self.heartrateValues.append([ Int((interfaceController?.videoGameTime)!) , Int(UInt16(value)) ])
           
        }
    }

    
    func login(){
        if(globalvariable.logged == 0){
            session = WCSession.default()
            session.delegate = self
            session.activate()
            print("activate")
            
            let message = ["userIsLogged": ""]
            self.session.sendMessage(message, replyHandler: nil, errorHandler: {
                error in
                print("-------------------------------------------")
                print(error.localizedDescription)
                print("-------------------------------------------")
            })
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if(globalvariable.logged == 0){
            session = WCSession.default()
            session.delegate = self
            session.activate()
            print("activate")
            
            let message = ["userIsLogged": ""]
            self.session.sendMessage(message, replyHandler: nil, errorHandler: {
                error in
                print("-------------------------------------------")
                print(error.localizedDescription)
                print("-------------------------------------------")
            })
        }
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompleted()
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompleted()
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompleted()
            default:
                // make sure to complete unhandled task types
                task.setTaskCompleted()
            }
        }
    }
    
    /*func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
        print("WATCH RECEBEU MSG")
    }*/
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any])
    {
        globalvariable.user_id = message["user_id"] as? Int
            
        if(globalvariable.user_id == 0){
            globalvariable.logged = 0
            let interfaceController = WKExtension.shared().rootInterfaceController as? InterfaceController
            interfaceController?.timerAfterOnline.invalidate()
            self.stopHeartMonitoring()
            
            WKInterfaceController.reloadRootControllers(withNames: ["Login View"], contexts: nil)
        }else{
            if(globalvariable.logged == 0){
                globalvariable.logged = 1
                WKInterfaceController.reloadRootControllers(withNames: ["Root View"], contexts: nil)
            }
            
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }

    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        //print("Received File with URL: \(file.fileURL)")
        let interfaceController = WKExtension.shared().rootInterfaceController as? InterfaceController
        
        let fm = FileManager()
        let container = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.marco.ReactIt")
        var dir = container?.appendingPathComponent("Videoteste.mp4")
        
        do{
            if(fm.fileExists(atPath: (dir?.path)!)){
                try fm.removeItem(at: dir!)
            }
            try fm.moveItem(at: file.fileURL, to: dir!)
            print("Download finished")
            
            
        } catch let err{
            print("Error = \(err)")
            print(err)
        }

        
        
    }
    
    func downloadVideo(){
        let message = ["video": ""]
        self.session.sendMessage(message, replyHandler: nil, errorHandler: {
            error in
            print("-------------------------------------------")
            print(error.localizedDescription)
            print("-------------------------------------------")
        })
    }

}
