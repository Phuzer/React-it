//
//  NotificationController.swift
//  React it
//
//  Created by Marco Cruz on 28/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications


class NotificationController: WKUserNotificationInterfaceController {
    
    @IBOutlet var game_info: WKInterfaceLabel!
    @IBOutlet var game_time: WKInterfaceLabel!
    @IBOutlet var notificationAlertLabel: WKInterfaceLabel!
    
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("activate")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
     override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
     // This method is called when a notification needs to be presented.
     // Implement it if you use a dynamic notification interface.
     // Populate your dynamic notification interface as quickly as possible.
     //
     // After populating your dynamic notification interface call the completion block.
        
        let identifier = notification.request.content.userInfo["identifier"] as? String
        let author = notification.request.content.userInfo["author"]
        let home_score = notification.request.content.userInfo["home_score"]
        let visitor_score = notification.request.content.userInfo["visitor_score"]
        let real_time = notification.request.content.userInfo["real_time"]
        
        if(identifier == "notification"){
            self.notificationAlertLabel.setText("\(author!) wants to know your reaction!")
        }else{
            let name = notification.request.content.userInfo["author"] as? String
            let opinion = notification.request.content.userInfo["opinion"] as? String
            let emotion = notification.request.content.userInfo["emotion"] as? String
            
            var op = ""
            switch(opinion!){
            case "up":
                op = "👍🏼"; break
            case "down":
                op = "👎🏼"; break
            default:
                break
            }
            
            var em = ""
            switch(emotion!){
            case "connected":
                em = "👏🏼"
                break
            case "elation":
                em = "😀"; break
            case "worry":
                em = "😨"; break
            case "surprise":
                em = "😮"; break
            case "unhappy":
                em = "😔"; break
            case "angry":
                em = "😠"; break
            default:
                break
            }

            self.notificationAlertLabel.setText("\(name!) reacted with \(op) \(em)")
        }
        
        self.game_info.setText("SWE \(home_score!)-\(visitor_score!) POR")
        self.game_time.setText("\(real_time!)")
        
     completionHandler(.custom)
     }
    
}
