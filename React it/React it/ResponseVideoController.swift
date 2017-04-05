//
//  ResponseVideoController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 11/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit

class ResponseVideoController: UIViewController {
    
    var moment_id: Int!

    @IBAction func Answer(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "responseOpinionSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let DestViewController : ResponseOpinionController = segue.destination as! ResponseOpinionController
        DestViewController.moment_id = self.moment_id
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
