//
//  GlobalVariables.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 29/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import Foundation

class GlobalVariables {
    
    var user_id: Int!
    var logged: Int!
    var server: String!
    var videoServer: String!
    //to help
    var moment: String!
    var milliseconds: String!
    var match_info: String!
    var home_team: String!
    var visitor_team: String!
    var author: String!
    
    var aux_controller: String!
    var aux_notification_control: Bool
    var aux_home_score: Int!
    var aux_visitor_score: Int!
    var aux_refresh_moments: Int!
    
    init(){
        
        self.user_id = 0
        self.logged = 0
        self.server = "http://marcomacpro.local:8181"
        //self.videoServer = "https://5a47c6c6.eu.ngrok.io"
        //self.videoServer = "https://j1rxg7ft0hn4fu63.v1.p.beameio.net"
        self.videoServer = "https://reactitstorage.tk/videos"
        self.moment = ""
        self.author = ""
        self.match_info = ""
        self.home_team = ""
        self.visitor_team = ""
        self.milliseconds = ""
        
        self.aux_controller = "normal"
        self.aux_notification_control = false
        self.aux_home_score = 0
        self.aux_visitor_score = 0
        self.aux_refresh_moments = 0
    }
}

var globalvariable = GlobalVariables()
