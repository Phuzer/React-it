//
//  Platform.swift
//  ClientPhoneApplication
//
//  Created by Marco Cruz on 08/08/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import Foundation

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
}
