//
//  ResponseEmotionController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 11/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import Alamofire

class ResponseEmotionController: UIViewController, EmotionViewDelegate {

    var moment_id: Int!
    var emotion: String!
    var opinion: String!
    var reactions: Int!
    var match_info = String()
    var moment = String()
    var milliseconds: Int!
    var author = String()
    var home_team: String!
    var visitor_team: String!
    var from_controller: String!
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var EmotionView: EmotionView!
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    fileprivate func setLoadingScreen(sentence:String) {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 140
        let height: CGFloat = 70
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        loadingView.frame = CGRect(x: screenWidth / 2 - 70 , y: screenHeight / 2 - 35 - 110 , width: width, height: height)
        loadingView.backgroundColor = UIColor(red:68/255.0, green:68/255.0, blue:68/255.0, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        // Sets loading text
        self.loadingLabel.font = UIFont(name: "Avenir Next", size: 16)
        self.loadingLabel.textColor = UIColor.white
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = sentence
        self.loadingLabel.frame = CGRect(x: 0, y: 12, width: 140, height: 70)
        self.loadingLabel.isHidden = false
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        self.spinner.frame = CGRect(x: 45, y: 0, width: 50, height: 50)
        self.spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.backView.addSubview(loadingView)
        self.parentView.bringSubview(toFront: self.backView)
        self.backView.isHidden = false
    }
    
    // Remove the activity indicator from the main view
    fileprivate func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
        self.backView.isHidden = true
        self.parentView.bringSubview(toFront: self.EmotionView)
        
    }
    
    func btn1(){
        self.emotion = "connected"
        sendMoment()
    }
    
    func btn2(){
        self.emotion = "elation"
        sendMoment()
    }
    
    func btn3(){
        self.emotion = "worry"
        sendMoment()
    }
    
    func btn4(){
        self.emotion = "surprise"
        sendMoment()
    }
    
    func btn5(){
        self.emotion = "unhappy"
        sendMoment()
    }
    
    func btn6(){
        self.emotion = "angry"
        sendMoment()
    }
    
    func sendMoment()
    {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        let userDefaults = UserDefaults.standard
        
        alamofire.request("\(globalvariable.server!)/postresponse", method: .get, parameters: ["userid": userDefaults.integer(forKey: "id"), "momentid": self.moment_id, "opinion": self.opinion, "emotion": self.emotion, "heartrate": ""]).validate()
            .responseData { response in
                
                switch response.result{
                    case .success(let data):
                    
                        let userDefaults = UserDefaults.standard
                        
                        var count = userDefaults.integer(forKey: "notificationCount")
                    
                        if(count >= 1){
                            if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController{
                                tabBarController.tabBar.items?.first?.badgeValue = nil
                                if(count - 1 != 0){
                                    tabBarController.tabBar.items?[0].badgeValue = "\(count-1)"
                                }
                                
                            }
                            
                            userDefaults.set(count-1, forKey: "notificationCount")
                            userDefaults.synchronize()
                        }
                            
                        
                        
                        let appearance = SCLAlertView.SCLAppearance(
                            kTitleFont: UIFont(name: "Avenir Next", size: 17)!,
                            showCloseButton: false
                        )
                        let alert = SCLAlertView(appearance: appearance)
                        alert.showSuccess("Opinion shared", subTitle: "", duration: 2)
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            globalvariable.aux_refresh_moments = 1
                            self.performSegue(withIdentifier: "endResponseSegue", sender: nil)
                        }
                        
                        break
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        let appearance = SCLAlertView.SCLAppearance(
                            kTitleFont: UIFont(name: "Avenir Next", size: 17)!,
                            showCloseButton: false
                        )
                        let alert = SCLAlertView(appearance: appearance)
                        alert.showError("Couldn't contact server", subTitle: "", duration: 2)
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            globalvariable.aux_refresh_moments = 1
                            self.performSegue(withIdentifier: "endResponseSegue", sender: nil)
                        }

                        break
                }
                alamofire.session.invalidateAndCancel()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "endResponseSegue"{
            let DestViewController : MomentController = segue.destination as! MomentController
            DestViewController.moment_id = self.moment_id
            DestViewController.moment = self.moment
            DestViewController.milliseconds = self.milliseconds
            DestViewController.reactions = self.reactions + 1
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
        self.EmotionView.delegate = self
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
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
