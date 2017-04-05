//
//  MyReactionsController.swift
//  React it
//
//  Created by Marco Cruz on 03/02/2017.
//  Copyright © 2017 Marco Cruz. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class MyReactionsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var myReactionsData = [[String]]()
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgDisclosure: UIImageView!
    
    var toggle = 1
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if(toggle == 0){
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: {
                self.imgDisclosure.transform = self.imgDisclosure.transform.rotated(by: CGFloat(M_PI_2))
                self.contentView.isHidden = false
            }, completion: nil)
            
            
            
            
            toggle = 1
        }else{
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: {
                self.imgDisclosure.transform = self.imgDisclosure.transform.rotated(by: CGFloat(-M_PI_2))
                self.contentView.isHidden = true
            }, completion: nil)
            
            toggle = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        topView.addGestureRecognizer(tap)
        topView.isUserInteractionEnabled = true
        //self.view.addSubview(topView)
        
        self.imgDisclosure.transform = self.imgDisclosure.transform.rotated(by: CGFloat(M_PI_2))
        
        myReactionsTableData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func myReactionsTableData()
    {
        let userDefaults = UserDefaults.standard
        let id = userDefaults.value(forKey: "id")
        
        Alamofire.request("\(globalvariable.server!)/reactions", method: .get, parameters: ["userid": id!]).responseJSON { response in
            //print(response)
            //to get status code
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    self.myReactionsData.removeAll()
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            self.myReactionsData.append(["\(JSON[i]["real_time"]!)", JSON[i]["opinion"]!, JSON[i]["emotion"]!])
                        }
                    }
                default:
                    self.myReactionsData.removeAll()
                    print("error with response status: \(status)")
                }
                self.tableView.reloadData()
                self.tableView.separatorStyle = .singleLine
            }
        }
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myReactionsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyReactionsCell", for: indexPath) as! MyReactionsCell
        let row = (indexPath as NSIndexPath).row
        
        cell.time.text = myReactionsData[row][0]
        
        var opinion = ""
        var emotion = ""
        
        if(myReactionsData[row][1] == "up"){
            opinion = "👍🏼"
        }else{
            opinion = "👎🏼"
        }
        
        if(myReactionsData[row][2] == "connected"){
            emotion = "👏🏼"
        }else if(myReactionsData[row][2] == "elation"){
            emotion = "😀"
        }else if(myReactionsData[row][2] == "worry"){
            emotion = "😨"
        }else if(myReactionsData[row][2] == "surprise"){
            emotion = "😮"
        }else if(myReactionsData[row][2] == "unhappy"){
            emotion = "😔"
        }else{
            emotion = "😠"
        }

        cell.reaction.text = "\(opinion) \(emotion)"
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }

}
