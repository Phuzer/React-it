//
//  WatchEmotionsController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 29/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class WatchEmotionsController: WKInterfaceController {
    
    var registerTime: Date!
    var opinion: String!
    
    
    @IBAction func btn1() {
        self.pushController(withName: "ReactionSend View", context: ["opinion": opinion, "emotion": "connected", "time": registerTime])
    }
    
    @IBAction func btn2() {
        self.pushController(withName: "ReactionSend View", context: ["opinion": opinion, "emotion": "elation", "time": registerTime])
    }
    
    @IBAction func btn3() {
        self.pushController(withName: "ReactionSend View", context: ["opinion": opinion, "emotion": "worry", "time": registerTime])
    }
    
    @IBAction func btn4() {
        self.pushController(withName: "ReactionSend View", context: ["opinion": opinion, "emotion": "surprise", "time": registerTime])
    }
    
    @IBAction func btn5() {
        self.pushController(withName: "ReactionSend View", context: ["opinion": opinion, "emotion": "unhappy", "time": registerTime])
    }
    
    @IBAction func btn6() {
        self.pushController(withName: "ReactionSend View", context: ["opinion": opinion, "emotion": "angry", "time": registerTime])
    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.opinion = (context as! NSDictionary)["opinion"] as! String
        self.registerTime = (context as! NSDictionary)["time"] as! Date
    
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        globalvariable.aux_notification_control = false
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    

}
