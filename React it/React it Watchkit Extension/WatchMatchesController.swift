//
//  WatchMatchesController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 29/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire


class WatchMatchesController: WKInterfaceController {

    
    @IBOutlet var content: WKInterfaceGroup!
    @IBOutlet var matchesTable: WKInterfaceTable!
    
    @IBOutlet var loader: WKInterfaceGroup!
    @IBOutlet var loading: WKInterfaceImage!
    
    var matchesInfo = [[String]]()
    
    weak var timer: Timer?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        //
        content.setHidden(true)
        loading.setImageNamed("spinner")
        loading.startAnimatingWithImages(in: NSMakeRange(0, 42), duration: 1, repeatCount: -1)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        globalvariable.aux_notification_control = false
        
        loadData()
        
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: true);
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        self.timer?.invalidate()
    }
    
    func loadData()
    {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        
        alamofire.request("\(globalvariable.server!)/matches").validate().responseJSON { response in
            switch response.result{
                case .success(let data):
                    self.matchesInfo.removeAll()
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            //["match_id", "match_info", "match_moments", "match_status", "home", "visitor"]
                            self.matchesInfo.append(["\(JSON[i]["match_id"]!)", " \(JSON[i]["home_abbr"]!) \(JSON[i]["home_score"]!)-\(JSON[i]["visitor_score"]!) \(JSON[i]["visitor_abbr"]!) ", "\(JSON[i]["moment_count"]!) moments", "\(JSON[i]["status"]!)", JSON[i]["home"]!, JSON[i]["visitor"]!, JSON[i]["home_abbr"]!, JSON[i]["visitor_abbr"]!])
                        }
                    }
                    self.setupTable()
                    break
                case .failure(let error):
                    self.matchesInfo.removeAll()
                    print("error with response error: \(error)")
                    break
            }
            alamofire.session.invalidateAndCancel()
        }
        
        print("updated matches table")
    }
    
    func setupTable() {
        loading.stopAnimating()
        loader.setHidden(true)
        content.setHidden(false)
        
        matchesTable.setNumberOfRows(matchesInfo.count, withRowType: "MatchRow")
        
        for i in 0 ..< matchesInfo.count {
            if let row = matchesTable.rowController(at: i) as? MatchRowController {
                row.matchInfo.setText(matchesInfo[i][1])
                row.moments.setText(matchesInfo[i][2])
                row.status.setText(matchesInfo[i][3])
                row.homeTeam.setImage(UIImage(named:"\(matchesInfo[i][4])-flag.png"))
                row.visitorTeam.setImage(UIImage(named:"\(matchesInfo[i][5])-flag.png"))
                
                if(matchesInfo[i][3] == "Live"){
                    row.status.setTextColor(UIColor(red: 0/255.0, green: 190/255.0, blue: 0/255.0, alpha: 1.0))
                    row.separator.setColor(UIColor(red: 0/255.0, green: 190/255.0, blue: 0/255.0, alpha: 1.0))
                }else{
                    row.status.setTextColor(UIColor(red: 190/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0))
                    row.separator.setColor(UIColor(red: 190/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0))
                }
            }
        }
        setTitle("Matches")
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        self.pushController(withName: "Moments View", context: ["match_id": Int(self.matchesInfo[rowIndex][0]), "match_info": self.matchesInfo[rowIndex][1], "home_team": self.matchesInfo[rowIndex][4], "visitor_team": self.matchesInfo[rowIndex][5]])
    }
    
}
