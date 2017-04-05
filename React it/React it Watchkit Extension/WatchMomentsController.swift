//
//  WatchMomentsController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 29/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class WatchMomentsController: WKInterfaceController, URLSessionDelegate, URLSessionDownloadDelegate{

    
    @IBOutlet var loading: WKInterfaceImage!
    @IBOutlet var loader: WKInterfaceGroup!
    @IBOutlet var content: WKInterfaceGroup!
    
    @IBOutlet var momentsTable: WKInterfaceTable!
    
    var match_id: Int!
    var match_info: String!
    var home_team: String!
    var visitor_team: String!
    var momentsInfo = [[String]]()
    var author: String!
    var moment: String!
    
    var selectedRow:Int!
    
    weak var timer: Timer?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        content.setHidden(true)
        loading.setImageNamed("spinner")
        loading.startAnimatingWithImages(in: NSMakeRange(0, 42), duration: 1, repeatCount: -1)
        
        self.match_id = (context as! NSDictionary)["match_id"] as! Int
        self.match_info = (context as! NSDictionary)["match_info"] as! String
        self.home_team = (context as! NSDictionary)["home_team"] as! String
        self.visitor_team = (context as! NSDictionary)["visitor_team"] as! String
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        globalvariable.aux_notification_control = false
        
        globalvariable.aux_controller = "normal"
        setTitle("Loading...")
        loadData()
        setTitle(self.match_info)
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: true);
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        self.timer?.invalidate()
    }

    
    fileprivate func convertTime(moment: String) -> Int{
        let timeArr = moment.characters.split{$0 == ":"}.map(String.init)
        let milliseconds = Int(timeArr[0])! * 60000 + Int(timeArr[1])! * 1000
        
        return milliseconds;
    }
    
    func loadData()
    {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        
        alamofire.request("\(globalvariable.server!)/moments", method: .get, parameters: ["matchid": self.match_id, "userid": globalvariable.user_id]).validate().responseJSON { response in
            switch response.result{
                case .success(let data):
                    let status = response.response?.statusCode
                    if(status == 201){
                        self.momentsInfo.removeAll()
                        if let result = response.result.value {
                            let JSON = result as! Array<Dictionary<String,String>>
                            for i in 0..<JSON.count{
                                //["moment_id", "moment", "author"]
                                self.momentsInfo.append(["\(JSON[i]["moment_id"]!)", "\(JSON[i]["time"]!)", "\(JSON[i]["first_name"]!) \(JSON[i]["last_name"]!)", "\(JSON[i]["resp"]!)", "\(JSON[i]["reactions"]!)", "\(JSON[i]["real_time"]!)", "\(JSON[i]["multiple_users"]!)", "\(JSON[i]["avatar"]!)"])
                            }
                            
                        }
                    }else{
                        self.momentsInfo.removeAll()
                        print("No moments.")
                    }
                    self.setupTable()
                    break
                case .failure(let error):
                    self.momentsInfo.removeAll()
                    print("error with response error: \(error)")
                    
                    break
            }
            alamofire.session.invalidateAndCancel()
        }
        print("updated moments table")
    }
    
    func setupTable() {
        loading.stopAnimating()
        loader.setHidden(true)
        content.setHidden(false)
        
        momentsTable.setNumberOfRows(momentsInfo.count, withRowType: "MomentRow")
        
        for i in 0 ..< momentsInfo.count {
            if let row = momentsTable.rowController(at: i) as? MomentRowController {
                if(momentsInfo[i][6] == "0"){
                    row.avatar.setImage(UIImage(named:"\(momentsInfo[i][7]).png"))
                }else{
                    row.avatar.setImage(UIImage(named:"Multiple.png"))
                }
                
                
                row.moment.setText(momentsInfo[i][5])
                if(momentsInfo[i][4] == "1"){
                    row.author.setText("\(momentsInfo[i][4]) reaction")
                }else{
                    row.author.setText("\(momentsInfo[i][4]) reactions")
                }
                
                if(momentsInfo[i][3] == "yes"){
                    row.momentStatus.setImage(UIImage(named:"disclosure.png"))
                }else{
                    row.momentStatus.setImage(UIImage(named:"play-btn.png"))
                }
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        if(momentsInfo[rowIndex][3] == "yes"){
            let controllers = ["MomentFirst", "MomentSecond", "MomentThird", "MomentFourth"]
            var array:[Any] = [Int(self.momentsInfo[rowIndex][0]), self.momentsInfo[rowIndex][5], self.momentsInfo[rowIndex][2], self.momentsInfo[rowIndex][4], self.match_info, self.home_team, self.visitor_team, "moments", Int(self.momentsInfo[rowIndex][1])]
            var moment_id = Int(self.momentsInfo[rowIndex][0])
            
            self.presentController(withNames: controllers, contexts: [array, moment_id, moment_id, moment_id])
        }else{
            
            self.selectedRow = rowIndex
            globalvariable.moment = self.momentsInfo[rowIndex][5]
            globalvariable.author = self.momentsInfo[rowIndex][4]
            globalvariable.milliseconds = self.momentsInfo[rowIndex][1]
            globalvariable.home_team = self.home_team
            globalvariable.visitor_team = self.visitor_team
            globalvariable.match_info = self.match_info
            
            let path = URL(string: "\(globalvariable.videoServer!)/Video\(momentsInfo[rowIndex][1]).mp4")
            
            let options = [
                WKMediaPlayerControllerOptionsAutoplayKey : NSNumber(value: true),
                WKMediaPlayerControllerOptionsVideoGravityKey : WKVideoGravity.resizeAspectFill.rawValue,
                WKMediaPlayerControllerOptionsLoopsKey : NSNumber(value: false),
                ] as [AnyHashable : Any]
            
            
            presentMediaPlayerController(with: path!, options: options) {
                didPlayToEnd, endTime, error in
                print(error)
                
                guard error == nil else{
                    print("Error occurred \(error)")
                    return
                }
                
                if didPlayToEnd{
                    print("Played to end of the file")
                } else {
                    print("Did not play to end of file. End time = \(endTime)")
                }
                
                self.goToOpinionResponse()
                
            }

            
        }
        
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let fm = FileManager()
        let container = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.opinionshare.app")
        var dir = container?.appendingPathComponent("video.mp4")
        
        do{
            if(fm.fileExists(atPath: (dir?.path)!)){
                try fm.removeItem(at: dir!)
            }
            try fm.moveItem(at: location, to: dir!)
            print("Download finished")
            
            let options = [
                WKMediaPlayerControllerOptionsAutoplayKey : NSNumber(value: true),
                WKMediaPlayerControllerOptionsVideoGravityKey : WKVideoGravity.resizeAspectFill.rawValue,
                WKMediaPlayerControllerOptionsLoopsKey : NSNumber(value: true),
                ] as [AnyHashable : Any]
            
            presentMediaPlayerController(with: dir!, options: options) {
                didPlayToEnd, endTime, error in
                print(error)
                    
                guard error == nil else{
                    print("Error occurred \(error)")
                    return
                }
                
                if didPlayToEnd{
                    print("Played to end of the file")
                } else {
                    print("Did not play to end of file. End time = \(endTime)")
                }
                
                self.goToOpinionResponse()
                
            }
            
        } catch let err{
            print("Error = \(err)")
            print(err)
        }
        
        session.invalidateAndCancel()
    }
    
    func goToOpinionResponse(){
        var moment_id:String = self.momentsInfo[self.selectedRow][0]
        
        self.pushController(withName: "Reaction Response View", context: ["moment_id": Int(moment_id)!, "match_info": globalvariable.match_info, "moment": globalvariable.moment, "author": globalvariable.author, "home_team": globalvariable.home_team, "visitor_team": globalvariable.visitor_team, "milliseconds": Int(globalvariable.milliseconds)])
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        var downloadStatus = totalBytesWritten * 100 / totalBytesExpectedToWrite
        setTitle("Download \(Int(downloadStatus))%")
        print("\(bytesWritten) / \(totalBytesExpectedToWrite)")
    }
    
    func urlSession( _ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("Resuming the download")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let e = error{
            print("Completed with error = \(e)")
        } else {
            print("Finished")
            setTitle(self.match_info)
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let e = error{
            print("Invalidated \(e)")
        } else {
            // no errors occurred, so that's all right
        }
    }
    

}
