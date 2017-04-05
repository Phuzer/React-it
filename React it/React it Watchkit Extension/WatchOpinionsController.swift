//
//  WatchOpinionsController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 29/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation


class WatchOpinionsController: WKInterfaceController {

    @IBOutlet var thumbsUpGroup: WKInterfaceGroup!
    @IBOutlet var thumbsDownGroup: WKInterfaceGroup!
        
    
    @IBAction func thumbsup() {
        animate(withDuration: 0.1, animations: {
            self.thumbsUpGroup.setAlpha(0.5)
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.1, animations: {
                    self.thumbsUpGroup.setAlpha(1)
                })
                DispatchQueue.main.asyncAfter(deadline: when + 0.1){
                    self.pushController(withName: "Emotion View", context: ["opinion": "up", "time": Date()])
                }
            }
        })
    }
    
    @IBAction func thumbsdown() {
        animate(withDuration: 0.1, animations: {
            self.thumbsDownGroup.setAlpha(0.5)
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.animate(withDuration: 0.1, animations: {
                    self.thumbsDownGroup.setAlpha(1)
                })
                DispatchQueue.main.asyncAfter(deadline: when + 0.1){
                    self.pushController(withName: "Emotion View", context: ["opinion": "down", "time": Date()])
                }
            }
        })
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        globalvariable.aux_notification_control = false
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
