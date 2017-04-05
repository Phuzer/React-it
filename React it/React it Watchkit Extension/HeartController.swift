//
//  HeartController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 19/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import Foundation
import WatchKit
import Alamofire

class HeartController: WKInterfaceController{
    
    @IBOutlet var success: WKInterfaceLabel!
    @IBOutlet var labelSending: WKInterfaceLabel!
    
    
    var registerTime: Date!
    var opinion: String!
    var emotion: String!
    var heartrate: String!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.opinion = (context as! NSDictionary)["opinion"] as! String
        self.emotion = (context as! NSDictionary)["emotion"] as! String
        self.registerTime = (context as! NSDictionary)["time"] as! Date
        
        saveMoment()
        
    }
    
    override func willActivate() {
        super.willActivate()
        
        globalvariable.aux_notification_control = false
    }
    
    func saveMoment(){
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        let timer = getMiliseconds(Date()) - getMiliseconds(self.registerTime)
        
        alamofire.request("\(globalvariable.server!)/postmoment", method: .get, parameters: ["userid": globalvariable.user_id, "matchid": 1, "opinion": self.opinion, "emotion": self.emotion, "compensation": timer, "heartrate": ""]).validate()
            .responseData { response in
                print(response)
                switch response.result{
                case .success(let data):
                    print("Moment shared with friends.")
                    
                    self.success.setHidden(false)
                    self.success.setAlpha(0.0)
                    self.animate(withDuration: 0.2, animations: {
                        self.labelSending.setAlpha(0.0)
                        let when = DispatchTime.now() + 0.2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.animate(withDuration: 0.2, animations: {
                                self.labelSending.setHidden(true)
                                self.success.setAlpha(1.0)
                            })
                            DispatchQueue.main.asyncAfter(deadline: when + 0.5){
                                WKExtension.shared().rootInterfaceController?.popToRootController()
                            }
                        }
                    })
                    
                    break
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    
                    self.success.setText("Server error")
                    self.success.setTextColor(UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0))
                    self.success.setHidden(false)
                    self.success.setAlpha(0.0)
                    self.animate(withDuration: 0.2, animations: {
                        self.labelSending.setAlpha(0.0)
                        let when = DispatchTime.now() + 0.2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.animate(withDuration: 0.2, animations: {
                                self.labelSending.setHidden(true)
                                self.success.setAlpha(1.0)
                            })
                            DispatchQueue.main.asyncAfter(deadline: when + 0.5){
                                WKExtension.shared().rootInterfaceController?.popToRootController()
                            }
                        }
                    })
                    break
                }
                alamofire.session.invalidateAndCancel()
        }
    }
    
    
    private func getMiliseconds(_ date: Date) -> Int
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([ .hour, .minute, .second], from: date)
        let hour = components.hour
        let minutes = components.minute
        let seconds = components.second
        
        return (((3600*hour!) + (60*minutes!) + seconds!) * 1000)
    }
}

