//
//  WatchMomentFourthController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 11/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class WatchMomentFourthController: WKInterfaceController {
    
    @IBOutlet var friendsTable: WKInterfaceTable!
    
    var friendsInfo = [[String]]()
    var moment_id: Int!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let moment_id = context as? Int {
            self.moment_id = moment_id
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        globalvariable.aux_notification_control = false
        
        loadData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @objc fileprivate func loadData()
    {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        
        alamofire.request("\(globalvariable.server!)/friendsreactions", method: .get, parameters: ["momentid": self.moment_id]).validate().responseJSON { response in
            switch response.result{
            case .success(let data):
                self.friendsInfo.removeAll()
                if let result = response.result.value {
                    let JSON = result as! Array<Dictionary<String,String>>
                    for i in 0..<JSON.count{
                        //["match_id", "match_info", "match_moments", "match_status", "home", "visitor"]
                        self.friendsInfo.append(["\(JSON[i]["first_name"]!)", "\(JSON[i]["last_name"]!.characters.first!).", "\(JSON[i]["opinion"]!)", "\(JSON[i]["emotion"]!)", "\(JSON[i]["avatar"]!)"])
                    }
                }
                self.setupTable()
                break
            case .failure(let error):
                self.friendsInfo.removeAll()
                print("error with response error: \(error)")
                break
            }
            alamofire.session.invalidateAndCancel()
        }
    }
    
    func setupTable() {
        friendsTable.setNumberOfRows(friendsInfo.count, withRowType: "FriendRow")
        
        for i in 0 ..< friendsInfo.count {
            if let row = friendsTable.rowController(at: i) as? FriendRowController {
                row.avatar.setImage(UIImage(named:"\(friendsInfo[i][4]).png"))
                row.name.setText(" \(friendsInfo[i][0]) \(friendsInfo[i][1])")
                                
                if(friendsInfo[i][2] == "up"){
                    row.opinion.setText("👍🏼")
                }else{
                    row.opinion.setText("👎🏼")
                }
                
                if(friendsInfo[i][3] == "connected"){
                    row.emotion.setText("👏🏼")
                }else if(friendsInfo[i][3] == "elation"){
                    row.emotion.setText("😀")
                }else if(friendsInfo[i][3] == "worry"){
                    row.emotion.setText("😨")
                }else if(friendsInfo[i][3] == "surprise"){
                    row.emotion.setText("😮")
                }else if(friendsInfo[i][3] == "unhappy"){
                    row.emotion.setText("😔")
                }else{
                    row.emotion.setText("😠")
                }

            }
        }
    }

}
