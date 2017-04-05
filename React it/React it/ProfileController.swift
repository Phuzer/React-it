//
//  ProfileController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 16/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit

class ProfileController: UIViewController{

    
    @IBOutlet weak var btnMatches: UIButton!
    @IBOutlet weak var imageViewBG: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBAction func logOut(_ sender: Any)
    {
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "logged")
        userDefaults.set([[Int]](), forKey: "heartrate")
        userDefaults.synchronize()
        
        let sharedUserDefaults = UserDefaults(suiteName: "K2844MSX92.group.marco.ReactIt")
        sharedUserDefaults?.set(false, forKey: "logged")
        sharedUserDefaults?.synchronize()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sendLogoutToWatch()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController?
        vc = storyboard.instantiateViewController(withIdentifier: "LoginController")
        UIApplication.shared.keyWindow?.rootViewController = vc
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let userDefaults = UserDefaults.standard
        labelName.text = userDefaults.value(forKey: "name") as! String?
        avatar.image = UIImage(named: "\(userDefaults.value(forKey: "avatar")!).png")
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
