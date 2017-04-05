//
//  WatchLoginController.swift
//  React it
//
//  Created by Marco Cruz on 15/01/2017.
//  Copyright © 2017 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation


class WatchLoginController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func login() {
        let watchDelegate = WKExtension.shared().delegate as? ExtensionDelegate
        watchDelegate?.login()
    }
}
