//
//  WatchOpinionResponseController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 13/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation


class WatchOpinionResponseController: WKInterfaceController {
    
    @IBOutlet var thumbsUpGroup: WKInterfaceGroup!
    @IBOutlet var thumbsDownGroup: WKInterfaceGroup!
    
    var moment_id: Int!
    var match_info = String()
    var moment = String()
    var author = String()
    var home_team: String!
    var visitor_team: String!
    var milliseconds: Int!
    
    @IBAction func thumbsUp() {
        animate(withDuration: 0.1, animations: {
            self.thumbsUpGroup.setAlpha(0.5)
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.1, animations: {
                    self.thumbsUpGroup.setAlpha(1)
                })
                DispatchQueue.main.asyncAfter(deadline: when + 0.1){
                    self.pushController(withName: "Emotion Response View", context: ["opinion": "up", "moment_id": self.moment_id, "moment": self.moment,"author": self.author, "match_info": self.match_info, "home_team": self.home_team, "visitor_team": self.visitor_team, "milliseconds": self.milliseconds])
                }
            }
        })
    }
    
    @IBAction func thumbsDown() {
        animate(withDuration: 0.1, animations: {
            self.thumbsDownGroup.setAlpha(0.5)
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.1, animations: {
                    self.thumbsDownGroup.setAlpha(1)
                })
                DispatchQueue.main.asyncAfter(deadline: when + 0.1){
                    self.pushController(withName: "Emotion Response View", context: ["opinion": "down", "moment_id": self.moment_id, "moment": self.moment,"author": self.author, "match_info": self.match_info, "home_team": self.home_team, "visitor_team": self.visitor_team, "milliseconds": self.milliseconds])
                }
            }
        })
    }
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    
        
        self.moment_id = (context as! NSDictionary)["moment_id"] as! Int
        self.match_info = (context as! NSDictionary)["match_info"] as! String
        self.moment = (context as! NSDictionary)["moment"] as! String
        self.author = (context as! NSDictionary)["author"] as! String
        self.home_team = (context as! NSDictionary)["home_team"] as! String
        self.visitor_team = (context as! NSDictionary)["visitor_team"] as! String
        self.milliseconds = (context as! NSDictionary)["milliseconds"] as! Int
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        globalvariable.aux_notification_control = false
        
        print("opinion \(globalvariable.aux_controller)")
        if(globalvariable.aux_controller! == "response"){
            self.pop()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
