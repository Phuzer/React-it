//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import Foundation

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()

//This route will be used to fetch data from the mysql database
routes.add(method: .get, uri: "/startvideo", handler: StartVideo)
routes.add(method: .get, uri: "/endvideo", handler: EndVideo)
routes.add(method: .get, uri: "/videotimer", handler: GetVideoTimer)
routes.add(method: .get, uri: "/setvideotimer", handler: SetVideoTimer)
routes.add(method: .get, uri: "/videostatus", handler: GetVideoStatus)
routes.add(method: .get, uri: "/setscores", handler: SetScores)
routes.add(method: .get, uri: "/video.mp4", handler: GetVideo)
routes.add(method: .get, uri: "/videowatch.mp4", handler: GetVideoWatch)
routes.add(method: .get, uri: "/postuser", handler: PostUser)
routes.add(method: .get, uri: "/postavatar", handler: PostAvatar)
routes.add(method: .get, uri: "/postmoment", handler: PostMoment)
routes.add(method: .get, uri: "/postresponse", handler: PostResponse)
routes.add(method: .get, uri: "/matches", handler: GetMatches)
routes.add(method: .get, uri: "/moments", handler: GetMoments)
routes.add(method: .get, uri: "/responses", handler: GetResponses)
routes.add(method: .get, uri: "/opinions", handler: GetOpinions)
routes.add(method: .get, uri: "/emotions", handler: GetEmotions)
routes.add(method: .get, uri: "/opinionsworldwide", handler: GetOpinionsWorldWide)
routes.add(method: .get, uri: "/emotionsworldwide", handler: GetEmotionsWorldWide)
routes.add(method: .get, uri: "/friendsreactions", handler: GetFriendsReactions)
routes.add(method: .get, uri: "/reactions", handler: GetMyReactions)
routes.add(method: .get, uri: "/thumbnail", handler: GetThumbnail)
routes.add(method: .get, uri: "/heartresponses", handler: GetHeartRateResponses)


// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8181
server.serverPort = 8181

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
    
	// Launch the HTTP server.
	try server.start()

} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
