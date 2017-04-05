//
//  UserController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 16/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Charts
import Alamofire


class UserController: UIViewController, UITextFieldDelegate{

    
    @IBOutlet weak var avatarContentView: UIView!
    @IBOutlet weak var labelHello: UILabel!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var labelError: UILabel!
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var loginView: UIView!
    
    
    
    @IBAction func tapBackView(_ sender: Any) {
        keyboardDismiss()
    }
    @IBAction func tapLoginView(_ sender: Any) {
        keyboardDismiss()
    }
    @IBAction func tapTitle(_ sender: Any) {
        keyboardDismiss()
    }
    
    @IBAction func logIn(_ sender: Any)
    {
        if(firstName.text == "" || lastName.text == ""){
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "Avenir Next", size: 17)!,
                showCloseButton: false
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.showError("Invalid login.", subTitle: "", duration: 2)
        }else{
            setLoadingScreen(sentence: "Logging In")
            
            let userDefaults = UserDefaults.standard
            let sharedUserDefaults = UserDefaults(suiteName: "K2844MSX92.group.marco.ReactIt")
            var device_token = userDefaults.string(forKey: "deviceToken")
            
            if Platform.isSimulator {
                device_token = "simulator"
            }
            
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 7
            let alamofire = Alamofire.SessionManager(configuration: configuration)
            
            alamofire.request("\(globalvariable.server!)/postuser", method: .get, parameters: ["firstname": firstName.text!, "lastname": lastName.text!, "device_token": device_token!]).validate().responseJSON { response in
                print(response)
                switch response.result{
                case .success(let data):
                    if let status = response.response?.statusCode {
                        switch(status){
                        case 201:
                            print("USER EXISTED")
                            let result = response.result.value
                            let JSON = result as! Array<Dictionary<String,String>>
                            
                            userDefaults.set(true, forKey: "logged")
                            userDefaults.set(Int(JSON[0]["user_id"]!), forKey: "id")
                            userDefaults.setValue("\(JSON[0]["first_name"]!) \(JSON[0]["last_name"]!)", forKey: "name")
                            userDefaults.setValue("\(JSON[0]["avatar"]!)", forKey: "avatar")
                            userDefaults.synchronize()
                            
                            sharedUserDefaults?.set(true, forKey: "logged")
                            sharedUserDefaults?.set(Int(JSON[0]["user_id"]!), forKey: "id")
                            sharedUserDefaults?.synchronize()
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            var vc = storyboard.instantiateViewController(withIdentifier: "MainController") as! UITabBarController
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.sendUserIdToWatch()
                            
                            self.performSegue(withIdentifier: "loginSegue", sender: nil)
                            self.labelError.text = ""
                            self.removeLoadingScreen()
                            break
                        case 202:
                            print("USER DIDNT EXIST")
                            let result = response.result.value
                            let JSON = result as! Array<Dictionary<String,String>>
                            let userDefaults = UserDefaults.standard
                            userDefaults.set(true, forKey: "logged")
                            userDefaults.set(Int(JSON[0]["user_id"]!), forKey: "id")
                            userDefaults.setValue("\(JSON[0]["first_name"]!) \(JSON[0]["last_name"]!)", forKey: "name")
                            userDefaults.synchronize()
                            
                            sharedUserDefaults?.set(true, forKey: "logged")
                            sharedUserDefaults?.set(Int(JSON[0]["user_id"]!), forKey: "id")
                            sharedUserDefaults?.synchronize()
                            
                            self.removeLoadingScreen()
                            self.avatarView.isHidden = false
                            break
                        default:
                            self.removeLoadingScreen()
                            let appearance = SCLAlertView.SCLAppearance(
                                kTitleFont: UIFont(name: "Avenir Next", size: 17)!,
                                showCloseButton: false
                            )
                            let alert = SCLAlertView(appearance: appearance)
                            alert.showError("Error", subTitle: "", duration: 2)
                            print("Request failed with error")
                            //self.labelError.text = "Error: couldn't contact the server."
                            
                            break
                            
                        }
                    }
                    break
                case .failure(let error):
                    self.removeLoadingScreen()
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "Avenir Next", size: 17)!,
                        showCloseButton: false
                    )
                    let alert = SCLAlertView(appearance: appearance)
                    alert.showError("Coundn't contact the server", subTitle: "", duration: 2)
                    print("Request failed with error")
                    //self.labelError.text = "Error: couldn't contact the server."
                    
                    break
                }
                alamofire.session.invalidateAndCancel()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        firstName.autocorrectionType = .no
        lastName.autocorrectionType = .no
        firstName.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        lastName.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        
        labelError.text = ""
        
        firstName.delegate = self
        firstName.returnKeyType = .done
        lastName.delegate = self
        lastName.returnKeyType = .done
    
        self.avatarContentView.layer.borderWidth = 1
        self.avatarContentView.layer.borderColor = UIColor(red:0/255.0, green:122/255.0, blue:0/255.0, alpha: 0.3).cgColor
        self.avatarContentView.layer.cornerRadius = 10;
        self.avatarContentView.layer.masksToBounds = true;
    }
    
    fileprivate func setLoadingScreen(sentence:String) {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 140
        let height: CGFloat = 70
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        loadingView.frame = CGRect(x: screenWidth / 2 - 75 , y: screenHeight / 2 - 35 , width: width, height: height)
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
        self.parentView.bringSubview(toFront: self.loginView)
        self.backView.isHidden = true
        
    }
    
    @IBAction func btnMan1(_ sender: Any) {
        setAvatar(avatar: "man1")
    }
    
    @IBAction func btnMan2(_ sender: Any) {
        setAvatar(avatar: "man2")
    }
    
    @IBAction func btnMan3(_ sender: Any) {
        setAvatar(avatar: "man3")
    }
    
    @IBAction func btnMan4(_ sender: Any) {
        setAvatar(avatar: "man4")
    }
    
    @IBAction func btnWoman1(_ sender: Any) {
        setAvatar(avatar: "woman1")
    }
    
    @IBAction func btnWoman2(_ sender: Any) {
        setAvatar(avatar: "woman2")
    }
    
    @IBAction func btnWoman3(_ sender: Any) {
        setAvatar(avatar: "woman3")
    }
    
    @IBAction func btnWoman4(_ sender: Any) {
        setAvatar(avatar: "woman4")
    }
    
    func setAvatar(avatar:String){
        
        setLoadingScreen(sentence: "Setting avatar")
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        let userDefaults = UserDefaults.standard
        
        alamofire.request("\(globalvariable.server!)/postavatar", method: .get, parameters: ["userid": userDefaults.integer(forKey: "id"), "avatar": avatar]).validate().responseData { response in
            switch response.result{
                case .success(let data):
                    userDefaults.setValue(avatar, forKey: "avatar")
                    userDefaults.synchronize()
                    self.labelError.text = ""
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.sendUserIdToWatch()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    var vc = storyboard.instantiateViewController(withIdentifier: "MainController") as! UITabBarController
                    UIApplication.shared.keyWindow?.rootViewController = vc

                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    
                    //self.removeLoadingScreen()
                    break
                case .failure(let error):
                    print("Request failed with error \(error)")
                    self.labelError.text = "Error: couldn't contact the server."
                    self.removeLoadingScreen()
                    break
                    
            }
            
            alamofire.session.invalidateAndCancel()
        }

    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardDismiss() {
        firstName.resignFirstResponder()
        lastName.resignFirstResponder()
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
