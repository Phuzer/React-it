//
//  VideoController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 10/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoController: UIViewController {
    
    @IBOutlet weak var loading_view: UIView!
    var playerView : AVPlayer!
    var playerViewController : AVPlayerViewController!
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    // Set the activity indicator into the main view
    fileprivate func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let x = (screenWidth / 2) - (width / 2)
        let y = (screenHeight / 2) - (height / 2) - 70  //(self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        //loadingView.backgroundColor = UIColor.blackColor()
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        self.loadingLabel.isHidden = false
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.loading_view.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    fileprivate func removeLoadingScreen() {
        // Hides and stops the text and the spinner
        self.spinner.stopAnimating()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when){
            self.playVideo()
        }
        setLoadingScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func playVideo()
    {
        let userDefaults = UserDefaults.standard
        let milliseconds = userDefaults.integer(forKey: "milliseconds")
        
        let videoImageUrl = "\(globalvariable.server!)/video.mp4?milliseconds=\(milliseconds)"
        let url = URL(string: videoImageUrl);
        let urlData = try? Data(contentsOf: url!);
        
        if(urlData != nil)
        {
            let file = "Video.mp4"
            let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
            let dir = dirs[0]; //documents
            let filePath = URL(fileURLWithPath: dir).appendingPathComponent(file)
            
            
            
            DispatchQueue.main.async(execute: {
                try? urlData?.write(to: filePath, options: [.atomic]);
                try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
                self.playerView = AVPlayer(url: filePath)
                self.playerViewController = AVPlayerViewController()
                self.playerViewController.player = self.playerView
                self.present(self.playerViewController, animated: true){
                    self.playerViewController.player?.play()
                    self.performSegue(withIdentifier: "notificationResponseOpinionSegue", sender: nil)
                }
                
                NotificationCenter.default.addObserver(self, selector: #selector(VideoController.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerView.currentItem)
            })
        }
        
    }
    
    func playerDidFinishPlaying(){
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "notificationResponseOpinionSegue"{
            let userDefaults = UserDefaults.standard
            removeLoadingScreen()
            
            let DestViewController : ResponseOpinionController = segue.destination as! ResponseOpinionController
            DestViewController.moment_id = userDefaults.integer(forKey: "momentid")
            DestViewController.milliseconds = userDefaults.integer(forKey: "milliseconds")
            DestViewController.moment = userDefaults.string(forKey: "real_time")!
            DestViewController.author = userDefaults.string(forKey: "author")!
            DestViewController.reactions = userDefaults.integer(forKey: "reactions")
            var match_info = "Sweden \(userDefaults.integer(forKey: "home_score")) - \(userDefaults.integer(forKey: "visitor_score")) Portugal"
            DestViewController.match_info = match_info
            DestViewController.home_team = "Sweden"
            DestViewController.visitor_team = "Portugal"
            DestViewController.from_controller = "Notification Response Controller"
            
            
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
