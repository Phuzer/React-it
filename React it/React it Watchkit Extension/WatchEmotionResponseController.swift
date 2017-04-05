//
//  WatchEmotionResponseController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 13/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class WatchEmotionResponseController: WKInterfaceController {
    
    
    @IBOutlet var content: WKInterfaceGroup!
    @IBOutlet var success: WKInterfaceLabel!
    
    var moment_id: Int!
    var opinion: String!
    var milliseconds: Int!
    var match_info = String()
    var moment = String()
    var author = String()
    var home_team: String!
    var visitor_team: String!
    
    @IBAction func btn1() {
        saveMoment(emotion: "connected")
    }
    
    @IBAction func btn2() {
        saveMoment(emotion: "elation")
    }
    
    @IBAction func btn3() {
        saveMoment(emotion: "worry")
    }
    
    @IBAction func btn4() {
        saveMoment(emotion: "surprise")
    }
    
    @IBAction func btn5() {
        saveMoment(emotion: "unhappy")
    }
    
    @IBAction func btn6() {
        saveMoment(emotion: "angry")
    }
    
    func saveMoment(emotion: String){
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        
        alamofire.request("\(globalvariable.server!)/postresponse", method: .get, parameters: ["userid": globalvariable.user_id, "momentid": self.moment_id, "opinion": self.opinion, "emotion": emotion, "heartrate": ""]).validate()
            .responseData { response in
                print(response)
                switch response.result{
                case .success(let data):
                    print("Moment shared with friends.")
                    
                    self.animate(withDuration: 0.2, animations: {
                        self.content.setAlpha(0.0)
                        let when = DispatchTime.now() + 0.2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.animate(withDuration: 0.2, animations: {
                                self.content.setHidden(true)
                                self.success.setAlpha(1.0)
                            })
                            DispatchQueue.main.asyncAfter(deadline: when + 0.5){
                                WKInterfaceController.reloadRootControllers(withNames: ["Root View"], contexts: nil)
                                
                            }
                        }
                    })
 
                    break
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    break
                }
                alamofire.session.invalidateAndCancel()
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.moment_id = (context as! NSDictionary)["moment_id"] as! Int
        self.opinion = (context as! NSDictionary)["opinion"] as! String
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
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
