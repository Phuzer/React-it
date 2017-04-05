//
//  InterfaceController.swift
//  OpinionShareWatch WatchKit Extension
//
//  Created by Marco Cruz on 29/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import UserNotifications

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var visitor_score: WKInterfaceLabel!
    @IBOutlet var home_score: WKInterfaceLabel!
    @IBOutlet var label_gameTime: WKInterfaceLabel!
    @IBOutlet var reactionsGroup: WKInterfaceGroup!
    @IBOutlet var shareGroup: WKInterfaceGroup!
    @IBOutlet var sharemoment: WKInterfaceImage!
    @IBOutlet var reactions: WKInterfaceImage!
    @IBOutlet var home_img: WKInterfaceImage!
    @IBOutlet var visitor_img: WKInterfaceImage!
    
    var timerBeforeOnline = Timer()
    var timerAfterOnline = Timer()
    var timerReajust = Timer()
    var videoGameTime:Int = 0
    
    var realTimers = [[Int]]()
    var indexRealTimers: Int = 0
    
    var heartMonitoringStarted:Bool = false
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        print("awake")
        
        realTimers.append([0,   0   ])
        realTimers.append([6,   0  ])
        realTimers.append([38,  842 ])
        realTimers.append([73,  2116])
        realTimers.append([98,  2268])
        realTimers.append([122, 2465])
        realTimers.append([147, 2645])
        realTimers.append([181, 2852])
        realTimers.append([219, 2891])
        realTimers.append([255, 2970])
        realTimers.append([304, 4008])
        realTimers.append([392, 4104])
        realTimers.append([434, 4208])
        realTimers.append([471, 4288])
        realTimers.append([530, 4567])
        realTimers.append([584, 4646])
        realTimers.append([692, 5476])
        realTimers.append([715, 5698])
            
        self.home_img.setImage(UIImage(named:"Sweden-flag.png"))
        self.visitor_img.setImage(UIImage(named:"Portugal-flag.png"))
    
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        globalvariable.aux_notification_control = false
        
        if(heartMonitoringStarted){
            self.timerReajust = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.reajustGameTime), userInfo: nil, repeats: true);
        }else{
            self.timerBeforeOnline = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.checkVideoOnline), userInfo: nil, repeats: true);
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        self.timerReajust.invalidate()
        self.timerBeforeOnline.invalidate()
    }
    
    func checkVideoOnline(){
        print("checkVideoOnline")
        Alamofire.request("http://marcomacpro.local:8181/videotimer")
            .validate()
            .responseJSON { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        let serverTime:Int = response.result.value as! Int
                        if(serverTime != 0){
                            
                            self.videoGameTime = serverTime/1000
                            for var i in 0...self.realTimers.count-1
                            {
                                if(self.videoGameTime < self.realTimers[i][0]){
                                    self.indexRealTimers = i - 1
                                    break
                                }
                                i = i + 1
                            }
                            if(self.videoGameTime > 5 && self.videoGameTime < 722){
                                self.timerBeforeOnline.invalidate()
                                self.timerAfterOnline = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateGameTime), userInfo: nil, repeats: true);
                            }
                            
                        }
                        break
                        
                    default:
                        print("Something went wrong")
                        break
                    }
                }
                
        }
    }
    
    func reajustGameTime(){
        print("Reajust")
        Alamofire.request("http://marcomacpro.local:8181/videotimer")
            .validate()
            .responseJSON { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        let serverTime:Int = response.result.value as! Int
                        if(serverTime != 0){
                            self.timerBeforeOnline.invalidate()
                            self.videoGameTime = serverTime/1000
                            for var i in 0...self.realTimers.count-1
                            {
                                if(self.videoGameTime < self.realTimers[i][0]){
                                    self.indexRealTimers = i - 1
                                    break
                                }
                                i = i + 1
                            }
                        }
                        break
                    default:
                        break
                    }
                }
        }
    }
    
    func updateGameTime(){
        print("update game time")
        if(self.videoGameTime > 5 && self.videoGameTime < 722){
            
            if(!self.heartMonitoringStarted){
                self.heartMonitoringStarted = true
                let watchDelegate = WKExtension.shared().delegate as? ExtensionDelegate
                watchDelegate?.startHeartMonitoring()
                self.timerReajust = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.reajustGameTime), userInfo: nil, repeats: true);
            }
            if(self.indexRealTimers < self.realTimers.count - 1){
                if(self.videoGameTime >= self.realTimers[self.indexRealTimers+1][0]){
                    self.indexRealTimers = self.indexRealTimers + 1
                }
            }
            var difference = self.videoGameTime - self.realTimers[self.indexRealTimers][0]
            var minutes = String( (self.realTimers[self.indexRealTimers][1] + difference) / 60)
            var seconds = String( (self.realTimers[self.indexRealTimers][1] + difference) % 60)
            
            if(seconds.characters.count == 1){
                seconds = "0\(seconds)"
            }
            
            if(minutes.characters.count == 1){
                minutes = "0\(minutes)"
            }
            
            self.label_gameTime.setText(minutes + ":" + seconds)
            self.videoGameTime = self.videoGameTime + 1
            
            if(self.videoGameTime < 267){
                self.home_score.setText("0")
                self.visitor_score.setText("0")
                globalvariable.aux_home_score = 0
                globalvariable.aux_visitor_score = 0
            }else if(self.videoGameTime >= 267 && self.videoGameTime < 341){
                self.home_score.setText("0")
                self.visitor_score.setText("1")
                globalvariable.aux_home_score = 0
                globalvariable.aux_visitor_score = 1
            }else if(self.videoGameTime >= 341 && self.videoGameTime < 487){
                self.home_score.setText("1")
                self.visitor_score.setText("1")
                globalvariable.aux_home_score = 1
                globalvariable.aux_visitor_score = 1
            }else if(self.videoGameTime >= 487 && self.videoGameTime < 538){
                self.home_score.setText("2")
                self.visitor_score.setText("1")
                globalvariable.aux_home_score = 2
                globalvariable.aux_visitor_score = 1
            }else if(self.videoGameTime >= 538 && self.videoGameTime < 624){
                self.home_score.setText("2")
                self.visitor_score.setText("2")
                globalvariable.aux_home_score = 2
                globalvariable.aux_visitor_score = 2
            }else if (self.videoGameTime >= 624){
                self.home_score.setText("2")
                self.visitor_score.setText("3")
                globalvariable.aux_home_score = 2
                globalvariable.aux_visitor_score = 3
            }
            
        }else{
            if(self.heartMonitoringStarted){
                self.heartMonitoringStarted = false
                let watchDelegate = WKExtension.shared().delegate as? ExtensionDelegate
                watchDelegate?.stopHeartMonitoring()
            }
            self.timerAfterOnline.invalidate()
            self.timerReajust.invalidate()
        }
    }
    
    @IBAction func shareMoment() {
        animate(withDuration: 0.1, animations: {
            self.shareGroup.setAlpha(0.5)
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.1, animations: {
                    self.shareGroup.setAlpha(1)
                })
                DispatchQueue.main.asyncAfter(deadline: when + 0.1){
                    self.pushController(withName: "Opinion View", context: nil)
                }
            }
        })
    }
    
    @IBAction func friendsReactions() {
        animate(withDuration: 0.1, animations: {
            self.reactionsGroup.setAlpha(0.5)
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.1, animations: {
                    self.reactionsGroup.setAlpha(1)
                })
                DispatchQueue.main.asyncAfter(deadline: when + 0.1){
                    self.pushController(withName: "Matches View", context: nil)
                }
            }
        })
    }
    
    override func handleAction(withIdentifier identifier: String?, for notification: UNNotification) {
        
        
        if(!globalvariable.aux_notification_control){
            globalvariable.aux_notification_control = true
            
            let identifier = notification.request.content.userInfo["identifier"] as! String
            let milliseconds = notification.request.content.userInfo["milliseconds"] as! Int
            let moment_id = notification.request.content.userInfo["momentid"] as! Int
            let real_time = notification.request.content.userInfo["real_time"] as! String
            let author = notification.request.content.userInfo["author"] as! String
            let home_score = notification.request.content.userInfo["home_score"] as! Int
            let visitor_score = notification.request.content.userInfo["visitor_score"] as! Int
            let match_info = "SWE \(home_score)-\(visitor_score) POR"
            
            if(identifier == "notification")
            {
                let path = URL(string: "\(globalvariable.videoServer!)/Video\(milliseconds).mp4")
                
                let options = [
                    WKMediaPlayerControllerOptionsAutoplayKey : NSNumber(value: true),
                    WKMediaPlayerControllerOptionsVideoGravityKey : WKVideoGravity.resizeAspectFill.rawValue,
                    WKMediaPlayerControllerOptionsLoopsKey : NSNumber(value: false),
                    ] as [AnyHashable : Any]
                
                
                presentMediaPlayerController(with: path!, options: options) {
                    didPlayToEnd, endTime, error in
                    
                    guard error == nil else{
                        print("Error occurred \(error)")
                        return
                    }
                    
                    self.pushController(withName: "Reaction Response View", context: ["moment_id": moment_id, "match_info": match_info, "moment": real_time, "author": author, "home_team": "Sweden", "visitor_team": "Portugal", "milliseconds": milliseconds])
                    
                }
            }else
            {
                let match_info = "SWE \(home_score)-\(visitor_score) POR"
                let controllers = ["MomentFirst", "MomentSecond", "MomentThird", "MomentFourth"]
                var array:[Any] = [moment_id, real_time, author, author, match_info, "Sweden", "Portugal", "moments", milliseconds]
                
                self.presentController(withNames: controllers, contexts: [array, moment_id, moment_id, moment_id])
            }
        }
        
    }
    
    @IBAction func tapGameReactions(_ sender: Any)
    {
        DispatchQueue.main.async{
            self.pushController(withName: "Moments View", context: ["match_id": 1, "match_info": "SWE \(globalvariable.aux_home_score!)-\(globalvariable.aux_visitor_score!) POR", "home_team": "Sweden", "visitor_team": "Portugal"])
        }
    }
    
    @IBAction func btnTeste() {
        let url = URL(string: "https://reactitstorage.tk/Video18000.mp4")
        
        presentMediaPlayerController(with: url!, options: nil) {
            didPlayToEnd, endTime, error in
            
            guard error == nil else{
                print("Error occurred \(error)")
                return
            }
            
        }
    }
    
    func playVideo(url: URL){
        presentMediaPlayerController(with: url, options: nil) {
            didPlayToEnd, endTime, error in
            
            guard error == nil else{
                print("Error occurred \(error)")
                return
            }
            
        }
    }
    
    
}
