//
//  NotificationResponseOpinionController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 02/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation

class NotificationResponseOpinionController: UIViewController, OpinionViewDelegate {
    
    
    @IBOutlet weak var OpinionView: OpinionView!
    
    var playerView : AVPlayer!
    var playerViewController : AVPlayerViewController!
    
    var milliseconds: Int!
    var moment_id: Int!
    var opinion: String!
    
    func btnThumbsUp(){
        self.opinion = "up"
        self.performSegue(withIdentifier: "notificationResponseEmotionSegue", sender: nil)
    }
    
    func btnThumbsDown(){
        self.opinion = "down"
        self.performSegue(withIdentifier: "notificationResponseEmotionSegue", sender: nil)
    }
    
    @IBAction func btnReplay(_ sender: UIButton)
    {
        let userDefaults = UserDefaults.standard
        let milliseconds = userDefaults.integer(forKey: "milliseconds")
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        
        //Running on iPhone
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
    }
    
    func playerDidFinishPlaying(){
        dismiss(animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "notificationResponseEmotionSegue"{
            let DestViewController : NotificationResponseEmotionController = segue.destination as! NotificationResponseEmotionController
            DestViewController.moment_id = self.moment_id
            DestViewController.opinion = self.opinion
            
        }
    }
    
    @IBAction func btnReturnHome(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: UITabBarController?
        vc = storyboard.instantiateViewController(withIdentifier: "MainController") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.OpinionView.delegate = self
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
