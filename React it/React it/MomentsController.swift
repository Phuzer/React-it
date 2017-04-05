//
//  SecondViewController.swift
//  ClientPhoneApplication
//
//  Created by Marco Cruz on 29/07/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation

class MomentsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    var playerView : AVPlayer!
    var playerViewController : AVPlayerViewController!
    var selectedRow: Int!
    
    weak var timer: Timer?
    
    var videoTimer = Timer()
    var videoState: Int! = 0
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageViewBG: UIImageView!
    @IBOutlet weak var imageViewHomeTeam: UIImageView!
    @IBOutlet weak var imageViewVisitorTeam: UIImageView!
    @IBOutlet weak var labelTeams: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noMomentsView: UIView!
    @IBOutlet weak var loading_view: UIView!
    
    var firstTimeLoading: Int! = 1
    
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    var match_id: Int!
    var match_info: String!
    var home_team: String!
    var visitor_team: String!
    var momentsInfo = [[String]]()
    var thumbnails = [UIImage]()
    let textCellIdentifier = "MomentsCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imageViewBG.addBlurEffect()
        topView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.40).cgColor
        topView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        topView.layer.shadowOpacity = 1.0
        topView.layer.shadowRadius = 4.0
        topView.layer.cornerRadius = 5.0
        labelTeams.text = match_info
        imageViewHomeTeam.image = UIImage(named:"\(home_team!)-flag.png")
        imageViewVisitorTeam.image = UIImage(named:"\(visitor_team!)-flag.png")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.noMomentsView.isHidden = true
        
        self.momentsInfo.removeAll()
        self.tableView.reloadData()
        self.setLoadingScreen()
        self.loadData()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func do_table_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(globalvariable.aux_refresh_moments == 1){
            print("refresh")
            globalvariable.aux_refresh_moments = 0
            self.momentsInfo.removeAll()
            self.tableView.reloadData()
            self.setLoadingScreen()
            self.loadData()
        }
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "onMomentsController")
        
        self.tabBarController?.tabBar.items?.first?.badgeValue = nil
        userDefaults.set(0, forKey: "notificationCount")
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
        
        self.timer?.invalidate()
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "onMomentsController")
        userDefaults.synchronize()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return momentsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! MomentsTableCell
        let row = (indexPath as NSIndexPath).row
        cell.labelMoments.text = momentsInfo[row][5]
        cell.imgViewThumbnail.image = self.thumbnails[row]
        
        cell.friendsReactions.text = "\(momentsInfo[row][4])"
        cell.globalReactions.text = "\(momentsInfo[row][8])"
        if(Int(momentsInfo[row][4])! >= 2){
            cell.trending.isHidden = false
        }else{
            cell.trending.isHidden = true
        }
        
        
        if(momentsInfo[row][6] == "0"){
            cell.avatar.image = UIImage(named: "\(momentsInfo[row][7]).png")
        }else{
            cell.avatar.image = UIImage(named: "Multiple.png")
        }
        
        var imageView : UIImageView
        if(momentsInfo[row][3] == "yes"){
            imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = UIImage(named:"disclosure.png")
        }else{
            imageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
            imageView.image = UIImage(named:"playclosure.png")
        }
        cell.accessoryView = imageView
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = (indexPath as NSIndexPath).row
        if(momentsInfo[row][3] == "no"){
            DispatchQueue.main.async(execute: {
                self.selectedRow = row
                self.playVideo(moment: self.momentsInfo[row][1])
            })
        }else{
            self.performSegue(withIdentifier: "momentSegue", sender: row)
        }
        
    }
    
    @objc fileprivate func update(){
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        let userDefaults = UserDefaults.standard
        
        alamofire.request("\(globalvariable.server!)/moments", method: .get, parameters: ["matchid": self.match_id, "userid": userDefaults.integer(forKey: "id")]).responseJSON { response in
            
            //to get status code
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    self.momentsInfo.removeAll()
                    self.noMomentsView.isHidden = true
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            //["moment_id", "moment", "author"]
                            self.momentsInfo.append(["\(JSON[i]["moment_id"]!)", "\(JSON[i]["time"]!)", "\(JSON[i]["first_name"]!) \(JSON[i]["last_name"]!)", "\(JSON[i]["resp"]!)", "\(JSON[i]["reactions"]!)", "\(JSON[i]["real_time"]!)", "\(JSON[i]["multiple_users"]!)", "\(JSON[i]["avatar"]!)", "\(JSON[i]["global"]!)"])
                        }
                        for var i in 0...self.momentsInfo.count-1
                        {
                            let imageUrl = "\(globalvariable.server!)/thumbnail?milliseconds=\(self.momentsInfo[i][1])"
                            let url = URL(string: imageUrl);
                            let urlData = try? Data(contentsOf: url!);
                            
                            if(urlData != nil)
                            {
                                self.thumbnails.append(UIImage(data: urlData!)!)
                            }
                            
                            i = i + 1
                        }
                    }
                case 501:
                    self.momentsInfo.removeAll()
                    self.noMomentsView.isHidden = false
                default:
                    print("error with response status: \(status)")
                }
            }
            self.tableView.separatorStyle = .singleLine
            alamofire.session.invalidateAndCancel()
        }
        
        self.do_table_refresh();
        print("Updated table Moments")
    }
    
    fileprivate func loadData()
    {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        let userDefaults = UserDefaults.standard
      
        alamofire.request("\(globalvariable.server!)/moments", method: .get, parameters: ["matchid": self.match_id, "userid": userDefaults.integer(forKey: "id")]).responseJSON { response in
            
            //to get status code
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    self.momentsInfo.removeAll()
                    self.noMomentsView.isHidden = true
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            //["moment_id", "moment", "author"]
                            self.momentsInfo.append(["\(JSON[i]["moment_id"]!)", "\(JSON[i]["time"]!)", "\(JSON[i]["first_name"]!) \(JSON[i]["last_name"]!)", "\(JSON[i]["resp"]!)", "\(JSON[i]["reactions"]!)", "\(JSON[i]["real_time"]!)", "\(JSON[i]["multiple_users"]!)", "\(JSON[i]["avatar"]!)", "\(JSON[i]["global"]!)"])
                       
                        }
                        
                        for var i in 0...self.momentsInfo.count-1
                        {
                            let imageUrl = "\(globalvariable.server!)/thumbnail?milliseconds=\(self.momentsInfo[i][1])"
                            let url = URL(string: imageUrl);
                            let urlData = try? Data(contentsOf: url!);
                            
                            if(urlData != nil)
                            {
                                self.thumbnails.append(UIImage(data: urlData!)!)
                            }
                            
                            i = i + 1
                        }
                    }
                case 501:
                    self.momentsInfo.removeAll()
                    self.noMomentsView.isHidden = false
                default:
                    self.momentsInfo.removeAll()
                    print("error with response status: \(status)")
                }
            }
            self.tableView.reloadData()
            self.tableView.separatorStyle = .singleLine
            self.removeLoadingScreen()
            alamofire.session.invalidateAndCancel()
        }
        
        self.do_table_refresh();
    }
    
    // Set the activity indicator into the main view
    fileprivate func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let x = (screenWidth / 2) - (width / 2)
        let y = (screenHeight / 2) - (height / 2) - 120 //(self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
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
        self.loading_view.isHidden = false
    }
    
    // Remove the activity indicator from the main view
    fileprivate func removeLoadingScreen() {
        // Hides and stops the text and the spinner
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
        self.loading_view.isHidden = true
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let row : Int = sender as! Int
        if segue.identifier == "momentSegue"{
            let DestViewController : MomentController = segue.destination as! MomentController
            DestViewController.moment_id = Int(self.momentsInfo[row][0])
            DestViewController.moment = self.momentsInfo[row][5]
            DestViewController.milliseconds = Int(self.momentsInfo[row][1])
            DestViewController.author = self.momentsInfo[row][2]
            DestViewController.reactions = Int(self.momentsInfo[row][4])
            DestViewController.match_info = self.match_info
            DestViewController.home_team = self.home_team
            DestViewController.visitor_team = self.visitor_team
            DestViewController.from_controller = "moments"
            
        } else if segue.identifier == "responseOpinionSegue"{
            let DestViewController : ResponseOpinionController = segue.destination as! ResponseOpinionController
            DestViewController.moment_id = Int(self.momentsInfo[row][0])
            DestViewController.milliseconds = Int(self.momentsInfo[row][1])
            DestViewController.moment_id = Int(self.momentsInfo[row][0])
            DestViewController.moment = self.momentsInfo[row][5]
            DestViewController.author = self.momentsInfo[row][2]
            DestViewController.reactions = Int(self.momentsInfo[row][4])
            DestViewController.match_info = self.match_info
            DestViewController.home_team = self.home_team
            DestViewController.visitor_team = self.visitor_team
            DestViewController.from_controller = "Moments Controller"
        }
    }

    fileprivate func convertTime(moment: String) -> Int{
        let timeArr = moment.characters.split{$0 == ":"}.map(String.init)
        let milliseconds = Int(timeArr[0])! * 60000 + Int(timeArr[1])! * 1000
        
        return milliseconds;
    }
    
    func playVideo(moment: String)
    {
        let videoImageUrl = "\(globalvariable.server!)/video.mp4?milliseconds=\(self.momentsInfo[self.selectedRow][1])"
        let url = URL(string: videoImageUrl);
        let urlData = try? Data(contentsOf: url!);
    
        if(urlData != nil)
        {
            if Platform.isSimulator {
                //Running on simulator
                print("running on simulator")
    
                let filePath = "/Users/marcocruz/Desktop/XCode/React it/Video.mp4"
    
                DispatchQueue.main.async(execute: {
                    try? urlData?.write(to: URL(fileURLWithPath: filePath), options: [.atomic]);
                    var fileURL: URL!
                    fileURL = URL(fileURLWithPath: "/Users/marcocruz/Desktop/XCode/React it/Video.mp4")
    
                    self.playerView = AVPlayer(url: fileURL)
                    self.playerViewController = AVPlayerViewController()
                    self.playerViewController.player = self.playerView
                    self.present(self.playerViewController, animated: true){
                        self.playerViewController.player?.play()
                    }
    
                    NotificationCenter.default.addObserver(self, selector: #selector(MomentsController.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerView.currentItem)
                })
    
            }else{
                //Running on iPhone
                print("running on iphone")
    
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
                        self.videoState = 1
                        self.playerViewController.player?.play()
                    }
    
                    NotificationCenter.default.addObserver(self, selector: #selector(MomentsController.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerView.currentItem)
                    
                    self.videoTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.checkVideoState), userInfo: nil, repeats: true);
                })
            }
        }
    }
    
    func playerDidFinishPlaying(){
        self.videoState = 0
        self.videoTimer.invalidate()
        self.performSegue(withIdentifier: "responseOpinionSegue", sender: self.selectedRow)
        dismiss(animated: true, completion: nil)
        
    }
    
    func checkVideoState(){
        if (self.playerViewController.player?.rate == 0 && self.playerViewController.isBeingDismissed && self.videoState == 1) {
            self.videoState = 0
            self.videoTimer.invalidate()
            self.performSegue(withIdentifier: "responseOpinionSegue", sender: self.selectedRow)
        }
    }
    
    func teste(){
        print("TESTE")
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

extension UIImageView {
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}

extension UIImage{
    
    func alpha(_ value:CGFloat)->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
        
    }
}
