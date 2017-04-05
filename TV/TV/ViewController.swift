//
//  ViewController.swift
//  ServerApplication
//
//  Created by Marco Cruz on 16/07/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation
import Alamofire

class ViewController: NSViewController{
    var videoPlayer:AVPlayer!
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    
    var timer = Timer()
    var goalIntervals = [Bool]()
    
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var playerView: AVPlayerView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        goalIntervals.append(false)
        goalIntervals.append(false)
        goalIntervals.append(false)
        goalIntervals.append(false)
        goalIntervals.append(false)
        goalIntervals.append(false)
    }
    
    @IBAction func btnPlay(_ sender: AnyObject)
    {
     
        setResult(home_score: 0,visitor_score: 0)
        
        let videoPath = "/Users/marcocruz/Desktop/XCode/TV/Sweden-Portugal-HD.mp4"
        let fileURL = URL(fileURLWithPath: videoPath)
        let avAsset = AVURLAsset(url: fileURL, options: nil)
        let playerItem = AVPlayerItem(asset: avAsset)
        videoPlayer = AVPlayer(playerItem: playerItem)
        playerView.player = videoPlayer
        playerView.player!.play()
        playerView.showsFullScreenToggleButton = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        //Alert the server that the video started
        Alamofire.request("http://marcomacpro.local:8181/startvideo")
            .validate()
            .responseData { response in
                switch response.result{
                case .success(let data):
                    print("start video success")
                    break
                case .failure(let error):
                    print("start video error")
                    break
                }
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
        
    }
    
    func playerDidFinishPlaying(){
        Alamofire.request("http://marcomacpro.local:8181/endvideo")
            .validate()
            .responseData { response in
                switch response.result{
                case .success(let data):
                    print("end video success")
                    break
                case .failure(let error):
                    print("end video error")
                    break
                }
        }
    }
    
    @IBAction func btnUpdate(_ sender: Any) {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        
        var timer = Int(videoPlayer.currentTime().seconds)
        
        alamofire.request("http://marcomacpro.local:8181/setvideotimer", method: .get, parameters: ["milliseconds": timer * 1000]).validate()
            .responseData { response in
                switch response.result{
                case .success(let data):
                    print("update success")
                    break
                case .failure(let error):
                    print("update error")
                    break
                }
                alamofire.session.invalidateAndCancel()
        }
        
    }

    
    func setResult(home_score:Int, visitor_score:Int){
        
        //print("set result")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        
        alamofire.request("http://marcomacpro.local:8181/setscores", method: .get, parameters: ["match_id": 1, "home_score": home_score, "visitor_score": visitor_score]).validate()
            .responseData { response in
                switch response.result{
                case .success(let data):
                    print("set result success")
                    break
                case .failure(let error):
                    print("set result success")
                    break
                }
                alamofire.session.invalidateAndCancel()
        }
        
    }
    
    func update(){
        var timer = Int(videoPlayer.currentTime().seconds)
        
        if(timer < 267 && !goalIntervals[0]){
            setResult(home_score: 0, visitor_score: 0)
            goalIntervals[0] = true
            goalIntervals[1] = false
            goalIntervals[2] = false
            goalIntervals[3] = false
            goalIntervals[4] = false
            goalIntervals[5] = false
            print("SWE 0 - 0 POR")
        }else if(timer >= 267 && timer < 341 && !goalIntervals[1]){
            setResult(home_score: 0, visitor_score: 1)
            goalIntervals[0] = false
            goalIntervals[1] = true
            goalIntervals[2] = false
            goalIntervals[3] = false
            goalIntervals[4] = false
            goalIntervals[5] = false
            print("SWE 0 - 1 POR")
        }else if(timer >= 341 && timer < 487 && !goalIntervals[2]){
            setResult(home_score: 1, visitor_score: 1)
            goalIntervals[0] = false
            goalIntervals[1] = false
            goalIntervals[2] = true
            goalIntervals[3] = false
            goalIntervals[4] = false
            goalIntervals[5] = false
            print("SWE 1 - 1 POR")
        }else if(timer >= 487 && timer < 538 && !goalIntervals[3]){
            setResult(home_score: 2, visitor_score: 1)
            goalIntervals[0] = false
            goalIntervals[1] = false
            goalIntervals[2] = false
            goalIntervals[3] = true
            goalIntervals[4] = false
            goalIntervals[5] = false
            print("SWE 2 - 1 POR")
        }else if(timer >= 538 && timer < 624 && !goalIntervals[4]){
            setResult(home_score: 2, visitor_score: 2)
            goalIntervals[0] = false
            goalIntervals[1] = false
            goalIntervals[2] = false
            goalIntervals[3] = false
            goalIntervals[4] = true
            goalIntervals[5] = false
            print("SWE 2 - 2 POR")
        }else if (timer >= 624 && !goalIntervals[5]){
            setResult(home_score: 2, visitor_score: 3)
            goalIntervals[0] = false
            goalIntervals[1] = false
            goalIntervals[2] = false
            goalIntervals[3] = false
            goalIntervals[4] = false
            goalIntervals[5] = true
            print("SWE 2 - 3 POR")
        }else{
            //
        }
        
    }

}

