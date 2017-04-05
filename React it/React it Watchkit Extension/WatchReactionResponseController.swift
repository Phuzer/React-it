//
//  WatchReactionResponseController.swift
//  React it
//
//  Created by Marco Cruz on 31/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class WatchReactionResponseController: WKInterfaceController {

    
    
    @IBOutlet var content_reaction: WKInterfaceGroup!
    @IBOutlet var content_opinion: WKInterfaceGroup!
    @IBOutlet var content_emotion: WKInterfaceGroup!
    @IBOutlet var sending: WKInterfaceLabel!
    @IBOutlet var message: WKInterfaceLabel!
    
    @IBOutlet var thumbsUpGroup: WKInterfaceGroup!
    @IBOutlet var thumbsDownGroup: WKInterfaceGroup!
    
    var moment_id: Int!
    var match_info = String()
    var moment = String()
    var author = String()
    var home_team: String!
    var visitor_team: String!
    var milliseconds: Int!
    
    var opinion: String!
    
    @IBAction func thumbsUp() {
        animate(withDuration: 0.1, animations: {
            self.thumbsUpGroup.setAlpha(0.5)
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.1, animations: {
                    self.thumbsUpGroup.setAlpha(1)
                })
                DispatchQueue.main.asyncAfter(deadline: when + 0.1){
                    self.opinion = "up"
                    self.changeScreenToEmotion()
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
                    self.opinion = "down"
                    self.changeScreenToEmotion()
                }
            }
        })
    }
    
    func changeScreenToSending(emotion: String){
        self.animate(withDuration: 0.2, animations: {
            self.content_emotion.setWidth(0.0)
            let when = DispatchTime.now() + 0.2
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.2, animations: {
                    self.content_emotion.setHidden(true)
                    self.saveMoment(emotion: emotion)
                })
            }
        })
    }
    
    @IBAction func btn1() {
        changeScreenToSending(emotion: "connected")
    }
    
    @IBAction func btn2() {
        changeScreenToSending(emotion: "elation")
    }
    
    @IBAction func btn3() {
        changeScreenToSending(emotion: "worry")
    }
    
    @IBAction func btn4() {
        changeScreenToSending(emotion: "surprise")
    }
    
    @IBAction func btn5() {
        changeScreenToSending(emotion: "unhappy")
    }
    
    @IBAction func btn6() {
        changeScreenToSending(emotion: "angry")
    }
    
    func saveMoment(emotion: String){
        
        //let userDefaults = UserDefaults.standard
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        
        print("moment_id: \(self.moment_id)")
        print("opinion: \(self.opinion)")
        print("emotion: \(emotion)")
        
        alamofire.request("\(globalvariable.server!)/postresponse", method: .get, parameters: ["userid": globalvariable.user_id, "momentid": Int(self.moment_id), "opinion": self.opinion, "emotion": emotion, "heartrate": ""]).validate()
            .responseData { response in
                print(response)
                switch response.result{
                case .success(let data):
                    print("Moment shared with friends.")
                    self.message.setHidden(false)
                    self.animate(withDuration: 0.1, animations: {
                        self.content_reaction.setHeight(0.0)
                        let when = DispatchTime.now() + 0.1
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.animate(withDuration: 0.1, animations: {
                                self.content_reaction.setHidden(true)
                            })
                            DispatchQueue.main.asyncAfter(deadline: when + 0.7){
            
                                let controllers = ["MomentFirst", "MomentSecond", "MomentThird", "MomentFourth"]
                                var array:[Any] = [self.moment_id, self.moment, self.author, self.author, self.match_info, self.home_team, self.visitor_team, "moments", self.milliseconds]
                                globalvariable.aux_refresh_moments = 1
                                self.pop()
                                
                            }
                        }
                    })
                    
                    break
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    self.message.setText("Server error")
                    self.message.setTextColor(UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0))
                    self.message.setHidden(false)
                    self.animate(withDuration: 0.1, animations: {
                        self.content_reaction.setHeight(0.0)
                        let when = DispatchTime.now() + 0.1
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.animate(withDuration: 0.1, animations: {
                                self.content_reaction.setHidden(true)
                            })
                            DispatchQueue.main.asyncAfter(deadline: when + 0.7){
                                
                                let controllers = ["MomentFirst", "MomentSecond", "MomentThird", "MomentFourth"]
                                var array:[Any] = [self.moment_id, self.moment, self.author, self.author, self.match_info, self.home_team, self.visitor_team, "moments", self.milliseconds]
                                
                                self.pop()
                                
                            }
                        }
                    })
                    break
                }
                alamofire.session.invalidateAndCancel()
        }
    }
    
    func changeScreenToEmotion(){
        setTitle("Emotion")
        self.animate(withDuration: 0.2, animations: {
            self.content_opinion.setWidth(0.0)
            let when = DispatchTime.now() + 0.2
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.2, animations: {
                    self.content_opinion.setHidden(true)
                })
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
        
        //self.message.setHidden(true)
        setTitle("Opinion")
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
