//
//  FirstViewController.swift
//  ClientPhoneApplication
//
//  Created by Marco Cruz on 29/07/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SwiftMessages

class RegisterController: UIViewController{
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var label_gameTime: UILabel!
    @IBOutlet weak var gameScore: UILabel!
    
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var label_gameState: UILabel!
    
    
    var timerBeforeOnline = Timer()
    var timerAfterOnline = Timer()
    var timerReajust = Timer()
    var videoGameTime:Int = 0
    
    var realTimers = [[Int]]()
    var indexRealTimers: Int = 0
    
    var playerView : AVPlayer!
    var playerViewController : AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //[video_time, real_time]
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
        
        self.timerBeforeOnline = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.checkVideoOnline), userInfo: nil, repeats: true);
        
        
        self.view.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 241/255.0, alpha: 1.0)
        
        self.navigationItem.title  = "REACT iT"
        
        topView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.70).cgColor
        topView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        topView.layer.shadowOpacity = 1.0
        topView.layer.shadowRadius = 4.0
        
        let userDefaults = UserDefaults.standard
        if (userDefaults.integer(forKey: "notificationCount") != 0){
            self.tabBarController?.tabBar.items?[0].badgeValue = "\(userDefaults.integer(forKey: "notificationCount"))"
        }
    }
    
    func checkVideoOnline(){
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
                            self.timerAfterOnline = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateGameTime), userInfo: nil, repeats: true);
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
        
        if(self.videoGameTime > 5 && self.videoGameTime < 722){
            self.label_gameState.text = "WATCHING"
            
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
            
            self.label_gameTime.text = minutes + ":" + seconds
            self.videoGameTime = self.videoGameTime + 1
            
            if(self.videoGameTime < 267){
                self.gameScore.text = "0 : 0"
                globalvariable.aux_home_score = 0
                globalvariable.aux_visitor_score = 0
            }else if(self.videoGameTime >= 267 && self.videoGameTime < 341){
                self.gameScore.text = "0 : 1"
                globalvariable.aux_home_score = 0
                globalvariable.aux_visitor_score = 1
            }else if(self.videoGameTime >= 341 && self.videoGameTime < 487){
                self.gameScore.text = "1 : 1"
                globalvariable.aux_home_score = 1
                globalvariable.aux_visitor_score = 1
            }else if(self.videoGameTime >= 487 && self.videoGameTime < 538){
                self.gameScore.text = "2 : 1"
                globalvariable.aux_home_score = 2
                globalvariable.aux_visitor_score = 1
            }else if(self.videoGameTime >= 538 && self.videoGameTime < 624){
                self.gameScore.text = "2 : 2"
                globalvariable.aux_home_score = 2
                globalvariable.aux_visitor_score = 2
            }else if (self.videoGameTime >= 624){
                self.gameScore.text = "2 : 3"
                globalvariable.aux_home_score = 2
                globalvariable.aux_visitor_score = 3
            }
            
        }else{
            self.label_gameState.text = "ENDED"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.timerReajust = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.reajustGameTime), userInfo: nil, repeats: true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timerReajust.invalidate()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    @IBAction func shareMoment(_ sender: UIButton)
    {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "opinionSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let DestViewController : OpinionController = segue.destination as! OpinionController
        DestViewController.registerTime = Date()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tapGameReactions(_ sender: UITapGestureRecognizer)
    {
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let momentsController = storyboard.instantiateViewController(withIdentifier: "MomentsController") as! MomentsController
        let matchesController = storyboard.instantiateViewController(withIdentifier: "MatchesController") as! MatchesController
        
        momentsController.match_id = 1
        momentsController.match_info = "Sweden \(globalvariable.aux_home_score!) - \(globalvariable.aux_visitor_score!) Portugal"
        momentsController.home_team = "Sweden"
        momentsController.visitor_team = "Portugal"
        
        /*let tab_matches = self.tabBarController?.viewControllers?[0] as! UINavigationController
        tab_matches.viewControllers = [matchesController, momentsController]
        self.tabBarController?.selectedIndex = 0*/
        
        self.navigationController?.pushViewController(momentsController, animated: true)
    }
    
    
}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


