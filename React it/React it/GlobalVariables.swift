//
//  GlobalVariables.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 29/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import Foundation

class GlobalVariables {
    
    var server: String!
    var videoServer: String!
    var aux_pressedReactions: Int!
    var aux_home_score: Int!
    var aux_visitor_score: Int!
    var aux_refresh_moments: Int!
    
    init(){
        self.server = "http://marcomacpro.local:8181"
        self.videoServer = "https://5a47c6c6.eu.ngrok.io"
        self.aux_pressedReactions = 0
        self.aux_home_score = 0
        self.aux_visitor_score = 0
        self.aux_refresh_moments = 0
    }
}

var globalvariable = GlobalVariables()
