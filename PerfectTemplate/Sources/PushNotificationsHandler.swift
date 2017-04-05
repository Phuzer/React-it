//
//  PushNotificationsHandler.swift
//  Server
//
//  Created by Marco Cruz on 21/08/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import PerfectLib
import PerfectNet
import PerfectThread
import PerfectHTTPServer
import PerfectHTTP
import PerfectNotifications
import AVFoundation

class PushNotificationsHandler {
    
    var configurationName: String!
    var n = NotificationPusher()
    
    
    init(configurationName: String) {
        print("Notification configuration started")
        //configurationName = "Push Notification Configuration"
        self.configurationName = configurationName
        NotificationPusher.addConfigurationIOS(name: self.configurationName!) {
            (net:NetTCPSSL) in
            
            net.keyFilePassword = ""
            
            guard net.useCertificateChainFile(cert: "/Users/marcocruz/Desktop/XCode/PerfectTemplate/entrust_2048_ca.cer") &&
                net.useCertificateFile(cert: "/Users/marcocruz/Desktop/XCode/PerfectTemplate/reactit.pem") &&
                net.usePrivateKeyFile(cert: "/Users/marcocruz/Desktop/XCode/PerfectTemplate/reactit.pem") &&
                net.checkPrivateKey() else {
                    
                    let code = Int32(net.errorCode())
                    print("Error validating private key file: \(net.errorStr(forCode: code))")
                    return
            }
        }
        
        NotificationPusher.development = true
        
        //let n = NotificationPusher()
        
        n.apnsTopic = "pt.marco.ReactIt"
    
    }
    
    func sendNotification(name:String, deviceIds: [String], momentId: Int, milliseconds: Int, real_time: String, reactions: Int, home_score: Int, visitor_score: Int)
    {
        
        let backgroundQueue = DispatchQueue(label: "com.app.queuenotification",
                                            qos: .background,
                                            target: nil)
        
        
        
        let ary = [ /*IOSNotificationItem.alertTitle("REACT iT"), */ IOSNotificationItem.alertBody("\(name) wants to know your reaction!"), IOSNotificationItem.sound("default"), IOSNotificationItem.customPayload("identifier", "notification"), IOSNotificationItem.customPayload("momentid", momentId), IOSNotificationItem.customPayload("real_time", real_time), IOSNotificationItem.customPayload("milliseconds", milliseconds), IOSNotificationItem.customPayload("reactions", reactions), IOSNotificationItem.customPayload("home_score", home_score), IOSNotificationItem.customPayload("visitor_score", visitor_score), IOSNotificationItem.customPayload("author", "\(name)")]
        
            
        
        if(deviceIds.count != 1){
            backgroundQueue.async{
                self.n.pushIOS(configurationName: self.configurationName!, deviceTokens: deviceIds, expiration: 0, priority: 10,    notificationItems: ary) {
                    response in
                        print("NOTIFICATIONS SENT (moment)")
                        print(deviceIds)
                }
            }
        }else{
            backgroundQueue.async{
                self.n.pushIOS(configurationName: self.configurationName!, deviceToken: deviceIds[0], expiration: 0, priority: 10, notificationItems: ary) {
                    response in
                    print("NOTIFICATIONS SENT (moment)")
                    print(deviceIds[0])
                }
            }
        }
            
            
            
        
    }
    
    func sendNotificationResponse(name:String, deviceIds: [String], opinion: String, emotion: String, real_time: String, momentId: Int, milliseconds: Int, reactions: Int, home_score: Int, visitor_score: Int)
    {
        let backgroundQueue = DispatchQueue(label: "com.app.queuenotificationresponse",
                                            qos: .background,
                                            target: nil)
        
            
        var op = ""
        switch(opinion){
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
        switch(emotion){
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
        
        let ary = [ /*IOSNotificationItem.alertTitle("REACT iT"), */ IOSNotificationItem.alertBody("\(name) reacted with \(op) \(em)"), IOSNotificationItem.sound("default"), IOSNotificationItem.customPayload("identifier", "notification response"), IOSNotificationItem.customPayload("opinion", opinion), IOSNotificationItem.customPayload("emotion", emotion), IOSNotificationItem.customPayload("momentid", momentId), IOSNotificationItem.customPayload("real_time", real_time), IOSNotificationItem.customPayload("milliseconds", milliseconds), IOSNotificationItem.customPayload("reactions", reactions), IOSNotificationItem.customPayload("home_score", home_score), IOSNotificationItem.customPayload("visitor_score", visitor_score), IOSNotificationItem.customPayload("author", "\(name)")]
        
        if(deviceIds.count != 1){
            backgroundQueue.async{
                self.n.pushIOS(configurationName: self.configurationName!, deviceTokens: deviceIds, expiration: 0, priority: 10, notificationItems: ary) {
                    response in
                    print("RESPONSE NOTIFICATIONS SENT")
                    print(deviceIds)
                }
            }
        }else{
            backgroundQueue.async{
                self.n.pushIOS(configurationName: self.configurationName!, deviceToken: deviceIds[0], expiration: 0, priority: 10, notificationItems: ary) {
                    response in
                    print("RESPONSE NOTIFICATIONS SENT")
                    print(deviceIds[0])
                }
            }
        }
        
        
        
    }

   
}
