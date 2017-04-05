//
//  WatchNotificationResponseController.swift
//  React it
//
//  Created by Marco Cruz on 05/01/2017.
//  Copyright © 2017 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation


class WatchNotificationResponseController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        print("awake")
        let path = URL(fileURLWithPath: "/Library/WebServer/Documents/Portugal-Sweden/Video23000.mp4")
        let options = [
            WKMediaPlayerControllerOptionsAutoplayKey : NSNumber(value: true),
            WKMediaPlayerControllerOptionsVideoGravityKey : WKVideoGravity.resizeAspectFill.rawValue,
            WKMediaPlayerControllerOptionsLoopsKey : NSNumber(value: false),
            ] as [AnyHashable : Any]
        
        
        presentMediaPlayerController(with: path, options: options) {
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
            
            print("DONE")
            
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("activate")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
