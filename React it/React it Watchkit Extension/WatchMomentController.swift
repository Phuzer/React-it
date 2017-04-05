//
//  WatchMomentController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 29/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire


class WatchMomentController: WKInterfaceController, URLSessionDelegate, URLSessionDownloadDelegate {
    
    
    @IBOutlet var content: WKInterfaceGroup!
    @IBOutlet var loader: WKInterfaceGroup!
    @IBOutlet var loading: WKInterfaceImage!
    
    @IBOutlet var loadingBar: WKInterfaceGroup!
    @IBOutlet var groupPlay: WKInterfaceGroup!
    @IBOutlet var groupThumbnail: WKInterfaceGroup!
    @IBOutlet var home_team_flag: WKInterfaceImage!
    @IBOutlet var visitor_team_flag: WKInterfaceImage!
    @IBOutlet var match_info_label: WKInterfaceLabel!
    @IBOutlet var moment_label: WKInterfaceLabel!
    
    
    var match_info = String()
    var moment = String()
    var author = String()
    var reactions = String()
    var moment_id: Int!
    var home_team: String!
    var visitor_team: String!
    var from_controller: String!
    var milliseconds: Int!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        content.setHidden(true)
        loading.setImageNamed("spinner")
        loading.startAnimatingWithImages(in: NSMakeRange(0, 42), duration: 1, repeatCount: -1)
        
        if let array = context as? [Any] {
            self.moment_id = array[0] as! Int
            self.match_info = array[4] as! String
            self.moment = array[1] as! String
            self.author = array[2] as! String
            self.reactions = array[3] as! String
            self.home_team = array[5] as! String
            self.visitor_team = array[6] as! String
            self.from_controller = array[7] as! String
            self.milliseconds = array[8] as! Int
        }
        
        self.match_info_label.setText(self.match_info)
        self.home_team_flag.setImage(UIImage(named:"\(self.home_team!)-flag.png"))
        self.visitor_team_flag.setImage(UIImage(named:"\(self.visitor_team!)-flag.png"))
        self.moment_label.setText(self.moment)
        self.groupPlay.setBackgroundImage(UIImage(named:"play-btn.png"))
        
        getThumbnail()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        globalvariable.aux_notification_control = false
        
        self.loadingBar.setWidth(0)
        self.loadingBar.setBackgroundColor(UIColor.black)
        
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    fileprivate func convertTime(moment: String) -> Int{
        print(moment)
        let timeArr = moment.characters.split{$0 == ":"}.map(String.init)
        let milliseconds = Int(timeArr[0])! * 60000 + Int(timeArr[1])! * 1000
        
        return milliseconds;
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let fm = FileManager()
        let container = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.marco.ReactIt")
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
                WKMediaPlayerControllerOptionsLoopsKey : NSNumber(value: false),
                ] as [AnyHashable : Any]
            
            self.loadingBar.setBackgroundColor(UIColor.black)
            self.loadingBar.setWidth(0.0)
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
                    
            }
            
        } catch let err{
            print("Error = \(err)")
            print(err)
        }
        
        session.invalidateAndCancel()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.loadingBar.setBackgroundColor(UIColor.green)
        var width:Double = Double(totalBytesWritten) * 150 / Double(totalBytesExpectedToWrite)
        self.loadingBar.setWidth(CGFloat(width))
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
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let e = error{
            print("Invalidated \(e)")
        } else {
            // no errors occurred, so that's all right
        }
    }
    
    func getThumbnail(){
        DispatchQueue.global().async {
            let url = URL(string: "\(globalvariable.server!)/thumbnail?milliseconds=\(self.milliseconds!)")!
            self.getDataFromUrl(url: url) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async(execute: {
                    self.groupThumbnail.setBackgroundImage(UIImage(data: data))
                    
                    self.loading.stopAnimating()
                    self.loader.setHidden(true)
                    self.content.setHidden(false)
                })
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    @IBAction func btnWatchVideo() {
        
        
        let path = URL(string: "\(globalvariable.videoServer!)/Video\(self.milliseconds!).mp4")

        
        let options = [
            WKMediaPlayerControllerOptionsAutoplayKey : NSNumber(value: true),
            WKMediaPlayerControllerOptionsVideoGravityKey : WKVideoGravity.resizeAspectFill.rawValue,
            WKMediaPlayerControllerOptionsLoopsKey : NSNumber(value: false),
            ] as [AnyHashable : Any]
        
        
        presentMediaPlayerController(with: path!, options: options) {
            didPlayToEnd, endTime, error in
            print(error)
            //self.dismissMediaPlayerController()
            
            guard error == nil else{
                print("Error occurred \(error)")
                return
            }
            
            if didPlayToEnd{
                print("Played to end of the file")
            } else {
                print("Did not play to end of file. End time = \(endTime)")
            }
            
        }
    }
    
    fileprivate func convertTime() -> Int{
        let time = self.moment
        let timeArr = time.characters.split{$0 == ":"}.map(String.init)
        let milliseconds = Int(timeArr[0])! * 60000 + Int(timeArr[1])! * 1000
        
        return milliseconds;
    }
    
}
