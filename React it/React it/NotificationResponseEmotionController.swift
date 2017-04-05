//
//  NotificationResponseEmotionController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 02/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import Alamofire

class NotificationResponseEmotionController: UIViewController, EmotionViewDelegate {
    
    var moment_id: Int!
    var milliseconds: Int!
    var emotion: String!
    var opinion: String!
    
    @IBOutlet weak var EmotionView: EmotionView!
    
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
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        let userDefaults = UserDefaults.standard

        alamofire.request("\(globalvariable.server!)/postresponse", method: .get, parameters: ["userid": userDefaults.integer(forKey: "id"), "momentid": self.moment_id, "opinion": self.opinion, "emotion": self.emotion, "heartrate": ""]).validate()
            .responseData { response in
                switch response.result{
                    case .success(let data):
                        let alert = UIAlertController(title: "", message: "Opinion shared.", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(alert, animated: true, completion: nil)
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            // your code with delay
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            var vc: UITabBarController?
                            vc = storyboard.instantiateViewController(withIdentifier: "MainController") as! UITabBarController
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }
                        break
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        let alert = UIAlertController(title: "", message: "Request error.", preferredStyle: UIAlertControllerStyle.alert)
                        self.present(alert, animated: true, completion: nil)
                        let when = DispatchTime.now() + 2
                        DispatchQueue.main.asyncAfter(deadline: when){
                            // your code with delay
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            var vc: UITabBarController?
                            vc = storyboard.instantiateViewController(withIdentifier: "MainController") as! UITabBarController
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        }
                        break
                }
             alamofire.session.invalidateAndCancel()   
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
        //self.view.backgroundColor = UIColor.black
        self.EmotionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
