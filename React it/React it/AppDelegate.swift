//
//  AppDelegate.swift
//  ClientPhoneApplication
//
//  Created by Marco Cruz on 17/07/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import UserNotifications
import HealthKit
import WatchConnectivity
import AVFoundation
import SwiftMessages

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    let healthStore = HKHealthStore()
    var session : WCSession!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if(WCSession.isSupported()){
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        
        
        let userDefaults = UserDefaults.standard
    
        
        UINavigationBar.appearance().tintColor = UIColor(red: 0/255.0, green: 150/255.0, blue: 0/255.0, alpha: 1.0)
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 100/255.0, blue: 0/255.0, alpha: 1.0)]
        
        let appearance = UITabBarItem.appearance()
        let attributes: [String: AnyObject] = [NSFontAttributeName:UIFont(name: "Avenir Next", size: 12)!]
        appearance.setTitleTextAttributes(attributes, for: .normal)
        UITabBar.appearance().tintColor = UIColor(red: 0/255.0, green: 150/255.0, blue: 0/255.0, alpha: 1.0)
        
        //Set initial controller
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var vc: UIViewController?
        let logged = userDefaults.bool(forKey: "logged")
        
        if (!logged){
            vc = storyboard.instantiateViewController(withIdentifier: "LoginController")
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        } else {
            vc = storyboard.instantiateInitialViewController()
        }
        
        
        
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                // Enable or disable features based on authorization.
            }
            application.registerForRemoteNotifications()
        } else {
            let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
            let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            
            application.registerUserNotificationSettings(pushNotificationSettings)
            application.registerForRemoteNotifications()
        }
        
        if let payload = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary, let identifier = payload["identifier"] as? String, let moment_id = payload["momentid"] as? Int, let milliseconds = payload["milliseconds"] as? Int, let real_time = payload["real_time"] as? String, let reactions = payload["reactions"] as? Int, let home_score = payload["home_score"] as? Int, let visitor_score = payload["visitor_score"] as? Int, let author = payload["author"] as? String{
            
            print("Notification click - APP turn off")
            
            var count = userDefaults.integer(forKey: "notificationCount")
            count = count + 1
            userDefaults.set(count, forKey: "notificationCount")
            userDefaults.synchronize()

            
            userDefaults.set(moment_id, forKey: "momentid")
            userDefaults.set(milliseconds, forKey: "milliseconds")
            userDefaults.set(real_time, forKey: "real_time")
            userDefaults.set(reactions, forKey: "reactions")
            userDefaults.set(home_score, forKey: "home_score")
            userDefaults.set(visitor_score, forKey: "visitor_score")
            userDefaults.set(author, forKey: "author")
            userDefaults.synchronize()

            if(identifier == "notification"){
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NotificationController")
                window?.rootViewController = vc
            }
            
        }
        
        if (logged && userDefaults.integer(forKey: "notificationCount") != 0){
            let tabBarController = self.window?.rootViewController as! UITabBarController
            tabBarController.tabBar.items?[0].badgeValue = "\(userDefaults.integer(forKey: "notificationCount"))"
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let userDefaults = UserDefaults.standard
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        userDefaults.setValue(deviceTokenString, forKey: "deviceToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Push notifications not available on simulator \(error)")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        if application.applicationState == UIApplicationState.active {
            print("Notification received - APP is active")
            
            let userDefaults = UserDefaults.standard
            let logged = userDefaults.bool(forKey: "logged")
            
            if(!logged){
                return
            }
            
            let id = userInfo["identifier"] as? String
            if(id! == "notification"){
                let systemSoundID: SystemSoundID = 1002
                AudioServicesPlaySystemSound (systemSoundID)
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                let userDefaults = UserDefaults.standard
                let moments = userDefaults.bool(forKey: "onMomentsController")
                var count = userDefaults.integer(forKey: "notificationCount")
                if(!moments){
                    count = count + 1
                    
                    if let tabBarController = self.window?.rootViewController as? UITabBarController{
                        tabBarController.tabBar.items?.first?.badgeValue = nil
                        tabBarController.tabBar.items?[0].badgeValue = "\(count)"
                    }
                    
                    userDefaults.set(count, forKey: "notificationCount")
                    userDefaults.synchronize()
                }
                
                let moment_id = userInfo["momentid"] as? Int
                let milliseconds = userInfo["milliseconds"] as? Int
                let real_time = userInfo["real_time"] as? String
                let reactions = userInfo["reactions"] as? Int
                let home_score = userInfo["home_score"] as? Int
                let visitor_score = userInfo["visitor_score"] as? Int
                let author = userInfo["author"] as? String
                
                let view = MessageView.viewFromNib(layout: .CardView)
                view.configureTheme(.warning)
                view.configureDropShadow()
                let body:String = "\(author!) wants to know your reaction!"
                view.configureContent(title: "Sweden - Portugal", body: body, iconText: "🤔")
                view.button?.isHidden = true
                view.iconImageView?.isHidden = true
                var config = SwiftMessages.defaultConfig
                config.duration = .seconds(seconds: 8)
                
                // Show the message.
                SwiftMessages.show(config: config, view: view)
                
                view.tapHandler = { _ in
                    SwiftMessages.hide()
                    
                    userDefaults.set(moment_id, forKey: "momentid")
                    userDefaults.set(milliseconds, forKey: "milliseconds")
                    userDefaults.set(real_time, forKey: "real_time")
                    userDefaults.set(reactions, forKey: "reactions")
                    userDefaults.set(home_score, forKey: "home_score")
                    userDefaults.set(visitor_score, forKey: "visitor_score")
                    userDefaults.set(author, forKey: "author")
                    userDefaults.synchronize()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let notificationController = storyboard.instantiateViewController(withIdentifier: "NotificationVideoController") as! VideoController
                    
                    if let topController = UIApplication.topViewController() {
                        topController.navigationController?.pushViewController(notificationController, animated: true)
                    }
                }
                
                


            }else{
                
                let systemSoundID: SystemSoundID = 1117
                AudioServicesPlaySystemSound (systemSoundID)
                
                let name = userInfo["author"] as? String
                let opinion = userInfo["opinion"] as? String
                let emotion = userInfo["emotion"] as? String
                let real_time = userInfo["real_time"] as? String
                
                var op = ""
                switch(opinion!){
                case "up":
                    op = "👍🏼"
                    break
                case "down":
                    op = "👎🏼"
                    break
                default:
                    break
                }
                
                var em = ""
                switch(emotion!){
                case "connected":
                    em = "👏🏼"
                    break
                case "elation":
                    em = "😀"
                    break
                case "worry":
                    em = "😨"
                    break
                case "surprise":
                    em = "😮"
                    break
                case "unhappy":
                    em = "😔"
                    break
                case "angry":
                    em = "😠"
                    break
                default:
                    break
                }

                
                let view = MessageView.viewFromNib(layout: .CardView)
                view.configureTheme(.success)
                view.configureDropShadow()
                
                let body:String = "\(name!) reacted to the minute \(real_time!)"
                view.configureContent(title: "Sweden - Portugal", body: body, iconText: "\(op) \(em)")
                view.button?.isHidden = true
                view.iconImageView?.isHidden = true
                var config = SwiftMessages.defaultConfig
                config.duration = .seconds(seconds: 8)
                
                // Show the message.
                SwiftMessages.show(config: config, view: view)
                
                view.tapHandler = { _ in
                    SwiftMessages.hide()
                    
                    let moment_id = userInfo["momentid"] as? Int
                    let milliseconds = userInfo["milliseconds"] as? Int
                    let real_time = userInfo["real_time"] as? String
                    let reactions = userInfo["reactions"] as? Int
                    let home_score = userInfo["home_score"] as? Int
                    let visitor_score = userInfo["visitor_score"] as? Int
                    let author = userInfo["author"] as? String
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let momentController = storyboard.instantiateViewController(withIdentifier: "MomentController") as! MomentController
                    
                    momentController.moment_id = moment_id
                    momentController.moment = real_time!
                    momentController.milliseconds = milliseconds
                    momentController.author = author!
                    momentController.reactions = reactions
                    momentController.match_info = "Sweden \(home_score!) - \(visitor_score!) Portugal"
                    momentController.home_team = "Sweden"
                    momentController.visitor_team = "Portugal"
                    momentController.from_controller = "moments"
                    
                    print("moment_id - \(moment_id)")
                    print("milliseconds - \(milliseconds)")
                    print("real_time - \(real_time)")
                    print("reactions - \(reactions)")
                    print("home_score - \(home_score)")
                    print("visitor_score - \(visitor_score)")
                    print("author - \(author)")
                    
                    
                    if let topController = UIApplication.topViewController() {
                        topController.navigationController?.pushViewController(momentController, animated: true)
                    }
                    
                }
            }
            
        }else{
            print("Notification click - APP on background")
            
            let id = userInfo["identifier"] as? String
            if(id! == "notification"){
                let moment_id = userInfo["momentid"] as? Int
                let milliseconds = userInfo["milliseconds"] as? Int
                let real_time = userInfo["real_time"] as? String
                let reactions = userInfo["reactions"] as? Int
                let home_score = userInfo["home_score"] as? Int
                let visitor_score = userInfo["visitor_score"] as? Int
                let author = userInfo["author"] as? String
                
                let userDefaults = UserDefaults.standard
                var count = userDefaults.integer(forKey: "notificationCount")
                count = count + 1
                userDefaults.set(count, forKey: "notificationCount")

                userDefaults.set(moment_id, forKey: "momentid")
                userDefaults.set(milliseconds, forKey: "milliseconds")
                userDefaults.set(real_time, forKey: "real_time")
                userDefaults.set(reactions, forKey: "reactions")
                userDefaults.set(home_score, forKey: "home_score")
                userDefaults.set(visitor_score, forKey: "visitor_score")
                userDefaults.set(author, forKey: "author")
                userDefaults.synchronize()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NotificationController")
                window?.rootViewController = vc
            }else{
                
            }
            
            
            
        }
        
        
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //globalService.start()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
        
        self.healthStore.handleAuthorizationForExtension { success, error in
            
        }
    }
    
    func sendUserIdToWatch()
    {
        if(WCSession.isSupported()){
            let userDefaults = UserDefaults.standard
            let message = ["user_id": userDefaults.value(forKey: "id")]
            self.session.sendMessage(message, replyHandler: nil, errorHandler: {
                error in print(error.localizedDescription)
            })
        }
    }
    
    func sendLogoutToWatch()
    {
        if(WCSession.isSupported()){
            let message = ["user_id": 0]
            self.session.sendMessage(message, replyHandler: nil, errorHandler: {
                error in print(error.localizedDescription)
            })
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if(WCSession.isSupported()){
            let userDefaults = UserDefaults.standard
        
            if let value = message["userIsLogged"] as? String{
                print("login")
                let logged = userDefaults.bool(forKey: "logged")
                
                if (!logged){
                    let message = ["user_id": 0]
                    self.session.sendMessage(message, replyHandler: nil, errorHandler: {
                        error in print(error.localizedDescription)
                    })
                }else{
                    let message = ["user_id": userDefaults.value(forKey: "id")]
                    self.session.sendMessage(message, replyHandler: nil, errorHandler: {
                        error in print(error.localizedDescription)
                    })
                }
            }
            
            if let values = message["heartrate"] as? [[Int]]{
                print("heartrate")
                userDefaults.set(values, forKey: "heartrate")
                userDefaults.synchronize()
                
                let file = "\(userDefaults.value(forKey: "id")!).txt"
                let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
                let dir = dirs[0]; //documents
                let filePath = URL(fileURLWithPath: dir).appendingPathComponent(file)
        
                DispatchQueue.main.async(execute: {
                    try? values.description.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
                })
                
            }
            
            if let values = message["video"] as? String{
                let videoImageUrl = "\(globalvariable.server!)/videowatch.mp4?milliseconds=\(21000)"
                let url = URL(string: videoImageUrl);
                let urlData = try? Data(contentsOf: url!);
                
                if(urlData != nil)
                {
                    
                    let fm = FileManager()
                    let container = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.marco.ReactIt")
                    var dir = container?.appendingPathComponent("Videoteste.mp4")
                    try? urlData?.write(to: dir!, options: [.atomic]);
                    
                    self.session.transferFile(dir!, metadata: nil)
                }
            }
            
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func sendVideoToWatch(){
        let videoImageUrl = "\(globalvariable.server!)/videowatch.mp4?milliseconds=\(21000)"
        let url = URL(string: videoImageUrl);
        let urlData = try? Data(contentsOf: url!);
        
        if(urlData != nil)
        {
            
            let fm = FileManager()
            let container = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.marco.ReactIt")
            var dir = container?.appendingPathComponent("Videoteste.mp4")
            try? urlData?.write(to: dir!, options: [.atomic]);
            
            self.session.transferFile(dir!, metadata: nil)
        }
        
        
    }

    

}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
