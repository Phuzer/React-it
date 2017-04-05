//
//  EmotionController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 06/11/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import Alamofire

class EmotionController: UIViewController, EmotionViewDelegate {
    
    var registerTime: Date!
    var emotion: String!
    var opinion: String!
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var EmotionView:EmotionView!
    
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
        setLoadingScreen(sentence: "Sending...")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        let userDefaults = UserDefaults.standard
        let timer = getMiliseconds(Date()) - getMiliseconds(self.registerTime)
        
        alamofire.request("\(globalvariable.server!)/postmoment", method: .get, parameters: ["userid": userDefaults.integer(forKey: "id"), "matchid": 1, "opinion": self.opinion, "emotion": self.emotion, "compensation": timer, "heartrate": ""]).validate()
            .responseData { response in
                print(response.result)
                switch response.result{
                    case .success(let data):
                        self.removeLoadingScreen()
                        let appearance = SCLAlertView.SCLAppearance(
                            kTitleFont: UIFont(name: "Avenir Next", size: 17)!,
                            showCloseButton: false
                        )
                        let alert = SCLAlertView(appearance: appearance)
                        alert.showSuccess("Moment shared with friends!", subTitle: "", duration: 2)
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.navigationController?.popToViewController(self.navigationController!.viewControllers[0], animated: true)
                            //alert.dismiss(animated: true, completion: nil)
                        }
                        
                        break
                    case .failure(let error):
                        self.removeLoadingScreen()
                        let appearance = SCLAlertView.SCLAppearance(
                            kTitleFont: UIFont(name: "Avenir Next", size: 17)!,
                            showCloseButton: false
                        )
                        let alert = SCLAlertView(appearance: appearance)
                        alert.showError("Video offline!", subTitle: "", duration: 2)
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            self.navigationController?.popToViewController(self.navigationController!.viewControllers[0], animated: true)
                            //alert.dismiss(animated: true, completion: nil)
                        }
    
                        break
                }
                
            alamofire.session.invalidateAndCancel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.EmotionView.delegate = self
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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
