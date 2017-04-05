//
//  FirstSecondViewController.swift
//  ClientPhoneApplication
//
//  Created by Marco Cruz on 29/07/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import Alamofire

class OpinionController: UIViewController, OpinionViewDelegate {
    
    var registerTime: Date!
    var opinion: String!

    @IBOutlet weak var OpinionView:OpinionView!
    
    func btnThumbsUp(){
        self.opinion = "up"
        self.performSegue(withIdentifier: "emotionSegue", sender: nil)
    }
    
    func btnThumbsDown(){
        self.opinion = "down"
        self.performSegue(withIdentifier: "emotionSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let DestViewController : EmotionController = segue.destination as! EmotionController
        DestViewController.registerTime = self.registerTime
        DestViewController.opinion = self.opinion
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.OpinionView.delegate = self
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
