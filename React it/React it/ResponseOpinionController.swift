//
//  ResponseOpinionController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 11/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation

class ResponseOpinionController: UIViewController, OpinionViewDelegate {
    
    
    @IBOutlet weak var OpinionView: OpinionView!
    @IBOutlet weak var btnReplay: UIButton!
    @IBOutlet weak var btnReplayHeight: NSLayoutConstraint!
    @IBOutlet weak var opinionViewConstraint: NSLayoutConstraint!

    
    var playerView : AVPlayer!
    var playerViewController : AVPlayerViewController!
    
    var milliseconds: Int!
    var moment_id: Int!
    var opinion: String!
    var reactions: Int!
    var match_info = String()
    var moment = String()
    var author = String()
    var home_team: String!
    var visitor_team: String!
    var from_controller: String!
    
    
    
    func btnThumbsUp(){
        self.opinion = "up"
        self.performSegue(withIdentifier: "responseEmotionSegue", sender: nil)
    }
    
    func btnThumbsDown(){
        self.opinion = "down"
        self.performSegue(withIdentifier: "responseEmotionSegue", sender: nil)
    }
    
    @IBAction func btnReplay(_ sender: UIButton)
    {
        DispatchQueue.main.async(execute: {
            
            print("running on iphone")
            
            let file = "Video.mp4"
            let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            let dir = dirs[0]; //documents
            let filePath = URL(fileURLWithPath: dir).appendingPathComponent(file)
            
            DispatchQueue.main.async(execute: {
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
                self.playerView = AVPlayer(url: filePath)
                self.playerViewController = AVPlayerViewController()
                self.playerViewController.player = self.playerView
                self.present(self.playerViewController, animated: true){
                    self.playerViewController.player?.play()
                }
                
                NotificationCenter.default.addObserver(self, selector: #selector(NotificationResponseOpinionController.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerView.currentItem)
            })
            
        })
        
    }
    
    func playerDidFinishPlaying(){
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func convertTime() -> Int{
        let time = self.moment
        let timeArr = time.characters.split{$0 == ":"}.map(String.init)
        let milliseconds = Int(timeArr[0])! * 60000 + Int(timeArr[1])! * 1000
        
        return milliseconds;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "responseEmotionSegue"{
            let DestViewController : ResponseEmotionController = segue.destination as! ResponseEmotionController
            DestViewController.moment_id = self.moment_id
            DestViewController.opinion = self.opinion
            DestViewController.reactions = self.reactions
            DestViewController.moment = self.moment
            DestViewController.milliseconds = self.milliseconds
            DestViewController.author = self.author
            DestViewController.match_info = self.match_info
            DestViewController.home_team = self.home_team
            DestViewController.visitor_team = self.visitor_team
            DestViewController.from_controller = self.from_controller
        } 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.OpinionView.delegate = self
    
        if(self.from_controller == "Notification Response Controller"){
            self.btnReplayHeight.constant = 100
            self.opinionViewConstraint.constant = -20
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if(self.from_controller == "Notification Response Controller"){
            if parent == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                var vc = storyboard.instantiateViewController(withIdentifier: "MainController") as! UITabBarController
                UIApplication.shared.keyWindow?.rootViewController = vc
            }
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
    
}
