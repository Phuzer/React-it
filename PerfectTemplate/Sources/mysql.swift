//
//  mysql.swift
//  PerfectTemplate
//
//  Created by Marco Cruz on 30/11/2016.
//
//

import Foundation
import PerfectLib
import MySQL
import PerfectHTTP
import AVFoundation
import AVKit
import Darwin

let host = "127.0.0.1"
let user = "root"
let password = "1234"
let database = "OpinionShare"

typealias TrimCompletion = (NSError?) -> ()
typealias TrimPoints = [(CMTime, CMTime)]

var videoStatus = "offline"
var videoStartTime: Date?
var millisecondsAhead: Int = 0
var home_score: Int = 0
var visitor_score: Int = 0
var realTimers = [[Int]]()
var firstTimeRunning = true
var pushNotificationsHandler:PushNotificationsHandler!

var userTestNumber: Int = 13

func updateNotifications(){
    
}

func setup(){
    
    if(firstTimeRunning){
        
        realTimers.append([0,   0   ])
        realTimers.append([6,   0   ])
        realTimers.append([38,  842 ])
        realTimers.append([73,  2116])
        realTimers.append([98,  2268])
        realTimers.append([122, 2465])
        realTimers.append([147, 2645])
        realTimers.append([181, 2852])
        realTimers.append([219, 2891])
        realTimers.append([255, 2970])
        realTimers.append([304, 4008])
        realTimers.append([392, 4104])
        realTimers.append([434, 4208])
        realTimers.append([471, 4288])
        realTimers.append([530, 4567])
        realTimers.append([584, 4646])
        realTimers.append([692, 5476])
        realTimers.append([715, 5698])
    }
    
    firstTimeRunning = false

}


//----------------------------------------------------------------------------------------------//

public func GetVideo(_ request: HTTPRequest, response: HTTPResponse)
{
    let milliseconds = Int(request.param(name: "milliseconds")!)!
    
    let docRoot = "/Library/WebServer/Documents/Portugal-Sweden"
    do {
        let trimmedVideo = File("\(docRoot)/Video\(milliseconds).mp4")
        let videoSize = trimmedVideo.size
        let videoBytes = try trimmedVideo.readSomeBytes(count: videoSize)
        response.addHeader(.contentType, value: "video/mp4")
        response.appendBody(bytes: videoBytes)
    } catch {
        //response.status = .custom(code: 500, message: "error")
        response.appendBody(string: "Error handling request: \(error)")
    }
    
    //response.status = .custom(code: 200, message: "success")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetVideoWatch(_ request: HTTPRequest, response: HTTPResponse)
{
    let milliseconds = Int(request.param(name: "milliseconds")!)!
    
    let docRoot = "/Library/WebServer/Documents/Portugal-Sweden-Watch"
    do {
        let trimmedVideo = File("\(docRoot)/Video\(milliseconds).mp4")
        let videoSize = trimmedVideo.size
        let videoBytes = try trimmedVideo.readSomeBytes(count: videoSize)
        response.addHeader(.contentType, value: "video/mp4")
        response.appendBody(bytes: videoBytes)
    } catch {
        //response.status = .custom(code: 500, message: "error")
        response.appendBody(string: "Error handling request: \(error)")
    }
    
    //response.status = .custom(code: 200, message: "success")
    response.completed()
}


//----------------------------------------------------------------------------------------------//

public func StartVideo(_ request: HTTPRequest, response: HTTPResponse)
{
    videoStartTime = Date();
    millisecondsAhead = 0;
    home_score = 0;
    visitor_score = 0;
    videoStatus = "online";
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "UPDATE Matches SET status = 'Live' WHERE match_id = 1;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    var randomNum:UInt32 = arc4random_uniform(10000)
    var configurationName:String = String(randomNum)
    pushNotificationsHandler = PushNotificationsHandler(configurationName: configurationName)
    
    response.status = .custom(code: 200, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func EndVideo(_ request: HTTPRequest, response: HTTPResponse)
{
    videoStatus = "offline";
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "UPDATE Matches SET status = 'Ended' WHERE match_id = 1;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    response.status = .custom(code: 200, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetVideoTimer(_ request: HTTPRequest, response: HTTPResponse)
{
    var timer: Int!
    if(videoStatus == "online"){
        timer = Date().millisecondsSince1970 - (videoStartTime?.millisecondsSince1970)! + millisecondsAhead
        response.appendBody(string: String(timer!))
    }else{
        response.appendBody(string: "0")
    }
    
    response.status = .custom(code: 200, message: "success")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetVideoStatus(_ request: HTTPRequest, response: HTTPResponse)
{
    response.appendBody(string: videoStatus)
    response.status = .custom(code: 200, message: "success")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func SetVideoTimer(_ request: HTTPRequest, response: HTTPResponse)
{
    millisecondsAhead = Int(request.param(name: "milliseconds")!)!
    videoStartTime = Date()
    
    response.status = .custom(code: 200, message: "success")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func SetScores(_ request: HTTPRequest, response: HTTPResponse)
{
    let match_id = Int(request.param(name: "match_id")!)!
    let homeScore = request.param(name: "home_score")!
    let visitorScore = request.param(name: "visitor_score")!
    
    home_score = Int(homeScore)!;
    visitor_score = Int(visitorScore)!;
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "UPDATE Matches SET home_score = '\(home_score)', visitor_score = '\(visitor_score)' WHERE match_id = '\(match_id)';") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    response.status = .custom(code: 200, message: "success")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func PostUser(_ request: HTTPRequest, response: HTTPResponse)
{
    let first_name = request.param(name: "firstname")!
    let last_name = request.param(name: "lastname")!
    let device_token = request.param(name: "device_token")!
    
    var userExisted: Bool!
    userExisted = true
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT * FROM Users WHERE first_name = '\(first_name)' AND last_name = '\(last_name)' AND active = 1;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    if(results?.numRows() == 0){
        userExisted = false
        let querySuccess2 = dataMysql.query(statement: "INSERT INTO Users (first_name, last_name, device_token, avatar) VALUES ('\(first_name)', '\(last_name)', '\(device_token)', '');")
        guard querySuccess2 else {
            response.status = .custom(code: 500, message: "Something went wrong")
            response.completed()
            return
        }
    }else{
        userExisted = true
        let querySuccess2 = dataMysql.query(statement: "UPDATE Users SET device_token = '\(device_token)' WHERE first_name = '\(first_name)' AND last_name = '\(last_name)' AND active = 1;")
        guard querySuccess2 else {
            response.status = .custom(code: 500, message: "Something went wrong")
            response.completed()
            return
        }
    }
    
    let querySuccess3 = dataMysql.query(statement: "SELECT user_id, first_name, last_name, avatar FROM Users WHERE first_name = '\(first_name)' AND last_name = '\(last_name)' AND active = 1;")
    guard querySuccess3 else {
        response.status = .custom(code: 500, message: "Something went wrong")
        response.completed()
        return
    }
    
    let results2 = dataMysql.storeResults()

    guard results2?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "User wansn't saved in the database.")
        response.appendBody(string: "User wansn't saved in the database.")
        response.completed()
        return
    }
    
    var resultArray = [[String:Any!]]()
    
    results2?.forEachRow { row in
        let user_id = row[0]
        let first_name = row[1]
        let last_name = row[2]
        let avatar = row[3]
        
        resultArray.append(["user_id":user_id, "first_name":first_name, "last_name":last_name, "avatar":avatar])
    }
   
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    if(userExisted == true){
        response.status = .custom(code: 201, message: "Success!")
    }else{
        response.status = .custom(code: 202, message: "Success!")
    }
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func PostAvatar(_ request: HTTPRequest, response: HTTPResponse)
{
    let user_id = Int(request.param(name: "userid")!)!
    let avatar = request.param(name: "avatar")!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "UPDATE Users SET avatar = '\(avatar)' WHERE user_id = '\(user_id)';") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    response.status = .custom(code: 200, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func PostMoment(_ request: HTTPRequest, response: HTTPResponse)
{
    if(videoStatus == "offline"){
        response.status = .custom(code: 500, message: "Video offline")
        response.completed()
        return
    }
    
    setup()
    
    let user_id = Int(request.param(name: "userid")!)!
    let match_id = Int(request.param(name: "matchid")!)!
    let compensation = Int(request.param(name: "compensation")!)!
    let opinion = request.param(name: "opinion")!
    let emotion = request.param(name: "emotion")!
    let heartrate = request.param(name: "heartrate")!
    
    var range: Int = 10000
    
    let dataMysql = MySQL()
    
    var timer = Date().millisecondsSince1970 - (videoStartTime?.millisecondsSince1970)! - compensation + millisecondsAhead
    timer = (timer + 500) / 1000
    timer = Int(Darwin.round(Double(timer)))
    timer = timer * 1000
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT * FROM Moments WHERE \(timer) BETWEEN (time - \(range)) AND (time + \(range)) AND userTestNumber = \(userTestNumber)") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    var results1 = dataMysql.storeResults()
    
    if(results1?.numRows() == 0){ //if there is no moment saved
        print("Moment didn't exist")
        var timerInSeconds = timer / 1000
        var index = 0
        for var i in 0...realTimers.count-1
        {
            if(timerInSeconds < realTimers[i][0]){
                index = i - 1
                break
            }
            i = i + 1
        }
        
        if(index < realTimers.count - 1){
            if(timerInSeconds >= realTimers[realTimers.count-1][0]){
                index = index + 1
            }
        }
        var difference: Int
        var minutes: String
        var seconds: String
        
        if(timerInSeconds >= realTimers[realTimers.count-1][0]){
            difference = timerInSeconds - realTimers[realTimers.count-1][0]
            minutes = String( (realTimers[realTimers.count-1][1] + difference) / 60)
            seconds = String( (realTimers[realTimers.count-1][1] + difference) % 60)
            
        }else{
            difference = timerInSeconds - realTimers[index][0]
            minutes = String( (realTimers[index][1] + difference) / 60)
            seconds = String( (realTimers[index][1] + difference) % 60)
        }
        
        
        
        
        
        if(seconds.characters.count == 1){
            seconds = "0\(seconds)"
        }
        if(minutes.characters.count == 1){
            minutes = "0\(minutes)"
        }
        var real_time = "\(minutes):\(seconds)"
        
        
        guard dataMysql.query(statement: "INSERT INTO Moments (user_id, match_id, time, real_time, userTestNumber) VALUES ('\(user_id)', '\(match_id)', \(timer), '\(real_time)', \(userTestNumber));") else {
            Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
            return
        }
        
        dataMysql.query(statement: "SET @last_id_in_Moments = LAST_INSERT_ID();")
        dataMysql.query(statement: "SELECT @last_id_in_Moments as last_moment;")
        
        var results2 = dataMysql.storeResults()
        
        var last_moment = 0
        results2?.forEachRow{ row in
            last_moment = Int(row[0]!)!
        }
        
        guard dataMysql.query(statement: "INSERT INTO Responses (moment_id, user_id, opinion, emotion, heartrate, userTestNumber) VALUES (@last_id_in_Moments, '\(user_id)', '\(opinion)', '\(emotion)', '\(heartrate)', \(userTestNumber));") else {
            Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
            return
        }
        
        let file = File("/Library/WebServer/Documents/Portugal-Sweden/Video\(timer).mp4")
        
        if(!file.exists){
            saveVideo(milliseconds: timer)
        }
        
        let backgroundQueue = DispatchQueue(label: "com.app.queue",
                                            qos: .background,
                                            target: nil)
        let when = DispatchTime.now() + 7
        backgroundQueue.asyncAfter(deadline: when){
            sendNotifications(user_id: user_id, moment_id: last_moment, milliseconds: Int(timer), real_time: real_time)
        }
        
        
    }else{ //a moment already exists within range
        print("Moment exists")
        var moment_id = 0
        results1?.forEachRow{ row in
            moment_id = Int(row[0]!)!
        }
        
        guard dataMysql.query(statement: "UPDATE Moments SET multiple_users = 1 WHERE moment_id = \(moment_id)") else {
            Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
            return
        }
        
        guard dataMysql.query(statement: "INSERT INTO Responses (moment_id, user_id, opinion, emotion, heartrate, userTestNumber) VALUES (\(moment_id), '\(user_id)', '\(opinion)', '\(emotion)', '\(heartrate)', \(userTestNumber));") else {
            Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
            return
        }
        
    }
    
    
    response.status = .custom(code: 200, message: "Success!")
    response.completed()
}

func sendNotifications(user_id:Int, moment_id:Int, milliseconds:Int, real_time: String)
{
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT first_name, last_name FROM Users WHERE user_id = \(user_id)") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    var name = ""
    results?.forEachRow{ row in
        if(row[1]! != ""){
            name = "\(row[0]!) \(row[1]!.characters.first!)."
        }else{
            name = "\(row[0]!)"
        }
    }
    
    guard dataMysql.query(statement: "SELECT moment_id, COUNT(*) as reactions FROM Responses WHERE moment_id = \(moment_id) GROUP BY moment_id") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results2 = dataMysql.storeResults()
    
    var reactions = "0"
    results2?.forEachRow{ row in
        reactions = "\(row[1]!)"
    }
    
    guard dataMysql.query(statement: "SELECT device_token FROM Users WHERE device_token NOT IN (SELECT device_token FROM Responses r JOIN Users u ON r.user_id = u.user_id WHERE moment_id = \(moment_id)) AND active = 1") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    var tokens = [String]()
    let results3 = dataMysql.storeResults()
    
    results3?.forEachRow{ row in
        tokens.append(row[0]!)
    }
    
    
    if(tokens.count != 0){
        pushNotificationsHandler.sendNotification(name: name, deviceIds: tokens, momentId: moment_id, milliseconds: milliseconds, real_time: real_time, reactions: Int(reactions)!, home_score: home_score, visitor_score: visitor_score)
    }
    
    
}

func saveVideo(milliseconds: Int)
{
    typealias TrimCompletion = (NSError?) -> ()
    typealias TrimPoints = [(CMTime, CMTime)]
    
    let sourceURL = NSURL(fileURLWithPath: "/Users/marcocruz/Desktop/XCode/TV/Sweden-Portugal.mp4")
    let destinationURL = NSURL(fileURLWithPath: "/Library/WebServer/Documents/Portugal-Sweden/Video\(milliseconds).mp4")
    let sourceURLWatch = NSURL(fileURLWithPath: "/Users/marcocruz/Desktop/XCode/TV/Sweden-Portugal_watch.mp4")
    let destinationURLWatch = NSURL(fileURLWithPath: "/Library/WebServer/Documents/Portugal-Sweden-Watch/Video\(milliseconds).mp4")
    
    let timeScale: Int32 = 1000
    
    var startTime = 0
    let endTime = Int(milliseconds)
    
    if((endTime - 10000) >= 0){
        startTime = endTime - 10000
    }
    
    let trimPoints = [(CMTimeMake(Int64(startTime), timeScale), CMTimeMake(Int64(endTime), timeScale))]
    
    /*if #available(OSX 10.11, *) {
        cropVideo(sourceURL: sourceURL, statTime: 10.0, endTime: 20.0, milliseconds: milliseconds)
    } else {
        // Fallback on earlier versions
    }*/
    
    let backgroundQueue = DispatchQueue(label: "com.app.queuetrimvideo",
                                        qos: .background,
                                        target: nil)
    backgroundQueue.async{
        trimVideo(sourceURL: sourceURL, destinationURL: destinationURL, trimPoints: trimPoints) { error in
            if let error = error {
                NSLog("Failure: \(error)")
            } else {
                NSLog("Success")
            }
            
        }
    }
    
    let backgroundQueueWatch = DispatchQueue(label: "com.app.queuetrimvideowatch",
                                        qos: .background,
                                        target: nil)
    backgroundQueueWatch.async{
        trimVideo(sourceURL: sourceURLWatch, destinationURL: destinationURLWatch, trimPoints: trimPoints) { error in
            if let error = error {
                NSLog("Failure: \(error)")
            } else {
                NSLog("Success")
            }
            
        }
    }
    
}

//----------------------------------------------------------------------------------------------//

public func PostResponse(_ request: HTTPRequest, response: HTTPResponse)
{
    let user_id = Int(request.param(name: "userid")!)!
    let moment_id = Int(request.param(name: "momentid")!)!
    let opinion = request.param(name: "opinion")!
    let emotion = request.param(name: "emotion")!
    let heartrate = request.param(name: "heartrate")!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "INSERT INTO Responses (moment_id, user_id, opinion, emotion, userTestNumber) VALUES ('\(moment_id)', '\(user_id)', '\(opinion)', '\(emotion)', \(userTestNumber));") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let backgroundQueue = DispatchQueue(label: "com.app.queueresponse",
                                        qos: .background,
                                        target: nil)
    let when = DispatchTime.now() + 3
    backgroundQueue.asyncAfter(deadline: when){
        sendNotificationsResponse(user_id: user_id, moment_id: moment_id, opinion: opinion, emotion: emotion)
    }
    
    response.status = .custom(code: 200, message: "Success!")
    response.completed()
}

func sendNotificationsResponse(user_id: Int, moment_id: Int, opinion: String, emotion: String){
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT first_name, last_name FROM Users WHERE user_id = \(user_id) AND active = 1") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    var name = ""
    results?.forEachRow{ row in
        if(row[1]! != ""){
            name = "\(row[0]!) \(row[1]!.characters.first!)."
        }else{
            name = "\(row[0]!)"
        }
    }

    guard dataMysql.query(statement: "SELECT user_id, multiple_users, real_time, time FROM Moments WHERE moment_id = \(moment_id)") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results2 = dataMysql.storeResults()
    
    var moment_owner_user_id = "0"
    var multiple_users = "0"
    var real_time = ""
    var time = ""
    
    results2?.forEachRow{ row in
        moment_owner_user_id = "\(row[0]!)"
        multiple_users = "\(row[1]!)"
        real_time = "\(row[2]!)"
        time = "\(row[3]!)"
    }
    
    guard dataMysql.query(statement: "SELECT moment_id, COUNT(*) as reactions FROM Responses WHERE moment_id = \(moment_id) GROUP BY moment_id") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results4 = dataMysql.storeResults()
    
    var reactions = "0"
    results4?.forEachRow{ row in
        reactions = "\(row[1]!)"
    }
    
    if(multiple_users == "0"){ //send notification to the user that started the moment
        
        print("only 1 response")
        
        guard dataMysql.query(statement: "UPDATE Moments SET multiple_users = 1 WHERE moment_id = \(moment_id)") else {
            Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
            return
        }
        
        guard dataMysql.query(statement: "SELECT device_token FROM Users WHERE user_id = \(moment_owner_user_id) AND active = 1") else {
            Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
            return
        }
        
        var tokens = [String]()
        let results3 = dataMysql.storeResults()
        
        results3?.forEachRow{ row in
            tokens.append(row[0]!)
        }
        
        if(tokens.count != 0){
            pushNotificationsHandler.sendNotificationResponse(name: name, deviceIds: tokens, opinion: opinion, emotion: emotion, real_time: real_time, momentId: moment_id, milliseconds: Int(time)!, reactions: Int(reactions)!, home_score: home_score, visitor_score: visitor_score)
        }
        
    }else{//send notification to everyone
        
        print("2 responses")
        
        guard dataMysql.query(statement: "SELECT device_token FROM Users WHERE user_id != \(user_id) AND active = 1") else {
            Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
            return
        }
        
        var tokens = [String]()
        let results3 = dataMysql.storeResults()
        
        results3?.forEachRow{ row in
            tokens.append(row[0]!)
        }
        
        
        if(tokens.count != 0){
            pushNotificationsHandler.sendNotificationResponse(name: name, deviceIds: tokens, opinion: opinion, emotion: emotion, real_time: real_time, momentId: moment_id, milliseconds: Int(time)!, reactions: Int(reactions)!, home_score: home_score, visitor_score: visitor_score)
        }
        
    }
    
}

//----------------------------------------------------------------------------------------------//

public func GetMatches(_ request: HTTPRequest, response: HTTPResponse)
{
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT match_id, home, visitor, home_score, visitor_score, status, (SELECT count(moment_id) FROM Moments WHERE match_id = m.match_id AND userTestNumber = \(userTestNumber)) AS moment_count, home_abbr, visitor_abbr FROM Matches m;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "No data!")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let match_id = row[0]
        let home = row[1]
        let visitor = row[2]
        let home_score = row[3]
        let visitor_score = row[4]
        let status = row[5]
        let moment_count = row[6]
        let home_abbr = row[7]
        let visitor_abbr = row[8]
        
        resultArray.append(["match_id":match_id, "home":home, "visitor":visitor, "home_score":home_score, "visitor_score":visitor_score, "status":status, "moment_count":moment_count, "home_abbr":home_abbr, "visitor_abbr":visitor_abbr])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetMoments(_ request: HTTPRequest, response: HTTPResponse)
{
    let user_id = Int(request.param(name: "userid")!)!
    let match_id = Int(request.param(name: "matchid")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT moment_id, first_name, last_name, time, real_time, IF(EXISTS(SELECT 1 FROM Responses r WHERE r.moment_id = mo.moment_id AND r.user_id = '\(user_id)'),'yes', 'no')AS resp, (SELECT count(*) FROM Responses WHERE Responses.moment_id = mo.moment_id) AS reactions, multiple_users, avatar, (SELECT count(*) FROM Responses resp JOIN Moments mom ON resp.moment_id = mom.moment_id WHERE mom.time between (mo.time - 10000) AND (mo.time + 10000)) as global FROM Matches ma NATURAL JOIN Moments mo NATURAL JOIN Users u WHERE match_id = '\(match_id)' AND userTestNumber = \(userTestNumber) ORDER BY time DESC;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
  
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 501, message: "No data.")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let moment_id = row[0]
        let first_name = row[1]
        let last_name = row[2]
        let time = row[3]
        let real_time = row[4]
        let resp = row[5]
        let reactions = row[6]
        let multiple_users = row[7]
        let avatar = row[8]
        let global = row[9]
        
        resultArray.append(["moment_id":moment_id, "first_name":first_name, "last_name":last_name, "time":time, "real_time":real_time, "resp":resp, "reactions":reactions, "multiple_users":multiple_users, "avatar":avatar, "global": global])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetResponses(_ request: HTTPRequest, response: HTTPResponse)
{
    let moment_id = Int(request.param(name: "momentid")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT first_name, last_name, opinion, emotion, avatar FROM Responses NATURAL JOIN Users WHERE moment_id = \(moment_id);") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "No data.")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let first_name = row[0]
        let last_name = row[1]
        let opinion = row[2]
        let emotion = row[3]
        let avatar = row[4]
        
        resultArray.append(["first_name":first_name, "last_name":last_name, "opinion":opinion, "emotion":emotion, "avatar":avatar])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()

}

//----------------------------------------------------------------------------------------------//

public func GetOpinions(_ request: HTTPRequest, response: HTTPResponse)
{
    let moment_id = Int(request.param(name: "momentid")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT opinion, count(*) as number FROM Responses WHERE moment_id = \(moment_id) GROUP BY opinion;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "No data!")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let opinion = row[0]
        let number = row[1]
        
        resultArray.append(["opinion":opinion, "number":number])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetOpinionsWorldWide(_ request: HTTPRequest, response: HTTPResponse)
{
    let moment_id = Int(request.param(name: "momentid")!)!
    let time = Int(request.param(name: "time")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT opinion, count(*) as number FROM Responses r JOIN Moments m ON r.moment_id = m.moment_id WHERE m.time between (\(time) - 10000) AND (\(time) + 10000) GROUP BY opinion;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "No data!")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let opinion = row[0]
        let number = row[1]
        
        resultArray.append(["opinion":opinion, "number":number])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetEmotions(_ request: HTTPRequest, response: HTTPResponse)
{
    let moment_id = Int(request.param(name: "momentid")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT emotion, count(*) as number FROM Responses WHERE moment_id = \(moment_id) GROUP BY emotion;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "No data!")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let emotion = row[0]
        let number = row[1]
        
        resultArray.append(["emotion":emotion, "number":number])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetEmotionsWorldWide(_ request: HTTPRequest, response: HTTPResponse)
{
    let moment_id = Int(request.param(name: "momentid")!)!
    let time = Int(request.param(name: "time")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT emotion, count(*) as number FROM Responses r JOIN Moments m ON r.moment_id = m.moment_id WHERE m.time between (\(time) - 10000) AND (\(time) + 10000) GROUP BY emotion;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "No data!")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let emotion = row[0]
        let number = row[1]
        
        resultArray.append(["emotion":emotion, "number":number])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetMyReactions(_ request: HTTPRequest, response: HTTPResponse)
{
    let user_id = Int(request.param(name: "userid")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT real_time, opinion, emotion, time from Moments m JOIN Responses r ON m.moment_id = r.moment_id WHERE r.user_id = \(user_id) ORDER BY time ASC;") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "No data!")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let real_time = row[0]
        let opinion = row[1]
        let emotion = row[2]
        let time = row[3]
        
        resultArray.append(["real_time":real_time, "opinion":opinion, "emotion":emotion, "time":time])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetFriendsReactions(_ request: HTTPRequest, response: HTTPResponse)
{
    let moment_id = Int(request.param(name: "momentid")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT first_name, last_name, opinion, emotion, avatar FROM Responses NATURAL JOIN Users WHERE moment_id = \(moment_id);") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    guard results?.numRows() != 0 else {
        response.status = .custom(code: 500, message: "No data!")
        response.appendBody(string: "Empty table.")
        response.completed(); return
    }
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let first_name = row[0]
        let last_name = row[1]
        let opinion = row[2]
        let emotion = row[3]
        let avatar = row[4]
        
        resultArray.append(["first_name":first_name, "last_name":last_name, "opinion":opinion, "emotion":emotion, "avatar":avatar])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 201, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetThumbnail(_ request: HTTPRequest, response: HTTPResponse)
{
    let milliseconds = Int(request.param(name: "milliseconds")!)!
    
    let docRoot = "/Library/WebServer/Documents/Thumbnails-Portugal-Sweden"
    do {
        let img = File("\(docRoot)/\(milliseconds).jpeg")
        let imageSize = img.size
        let imageBytes = try img.readSomeBytes(count: imageSize)
        response.addHeader(.contentType, value: "image/jpeg")
        response.appendBody(bytes: imageBytes)
    } catch {
        response.appendBody(string: "Error handling request: \(error)")
    }
    
    response.completed()
}

//----------------------------------------------------------------------------------------------//

public func GetHeartRateResponses(_ request: HTTPRequest, response: HTTPResponse)
{
    let user_id = Int(request.param(name: "user_id")!)!
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT time, real_time, heartrate FROM Responses NATURAL JOIN Moments WHERE user_id = \(user_id) AND heartrate != '' ORDER BY time ASC") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    var resultArray = [[String:Any!]]()
    
    results?.forEachRow { row in
        let time = row[0]
        let real_time = row[1]
        let heartrate = row[2]
        
        resultArray.append(["time":time, "real_time":real_time, "heartrate":heartrate])
    }
    
    do{
        let data = try JSONSerialization.data(withJSONObject: resultArray, options: .prettyPrinted)
        let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        response.appendBody(string: string as! String)
        
    } catch {
        print(error.localizedDescription)
    }
    
    response.status = .custom(code: 200, message: "Success!")
    response.completed()
}

//----------------------------------------------------------------------------------------------//


public func useMysql(_ request: HTTPRequest, response: HTTPResponse) {
    
    let dataMysql = MySQL()
    
    guard dataMysql.connect(host: host, user: user, password: password ) else {
        Log.info(message: "Failure connecting to data server \(host)")
        return
    }
    
    defer {
        dataMysql.close()  // defer ensures we close our db connection at the end of this request
    }
    
    guard dataMysql.selectDatabase(named: database) && dataMysql.query(statement: "SELECT * FROM Users") else {
        Log.info(message: "Failure: \(dataMysql.errorCode()) \(dataMysql.errorMessage())")
        return
    }
    
    let results = dataMysql.storeResults()
    
    var resultArray = [[String!]]()
    
    let numRows = results?.numRows()
    var jsonObject = [[String: String]]()
    for _ in 0 ... numRows!-1 {
        let row = results?.next()
        jsonObject.append([
            "user_id" : (row?[0])!,
            "first_name" : (row?[1])!,
            "last_name" : (row?[2])!
        ])
    }
    
    //return array to http response
    response.appendBody(string: "\(jsonObject)")
    
    response.completed()
}

//----------------------------------------------------------------------------------------------//

func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool
{
    let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
    let filteredPresets = compatiblePresets.filter { $0 == preset }
    return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
}

func removeFileAtURLIfExists(url: NSURL)
{
    if let filePath = url.path {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            } catch {
                NSLog("Couldn't remove existing destination file")
            }
        }
    }
}

func trimVideo(sourceURL: NSURL, destinationURL: NSURL, trimPoints: TrimPoints, completion: TrimCompletion?)
{
    assert(sourceURL.isFileURL)
    assert(destinationURL.isFileURL)
    
    let options = [ AVURLAssetPreferPreciseDurationAndTimingKey: true ]
    let asset = AVURLAsset(url: sourceURL as URL, options: options)
    var preferredPreset = AVAssetExportPresetPassthrough
    if #available(OSX 10.11, *) {
        preferredPreset = AVAssetExportPresetMediumQuality
    } else {
        // Fallback on earlier versions
    }
    if verifyPresetForAsset(preset: preferredPreset, asset: asset)
    {
        let composition = AVMutableComposition()
        let videoCompTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
        let audioCompTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
        let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first as AVAssetTrack!
        let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first as AVAssetTrack!
        let compError: NSError?
        compError = nil
        var accumulatedTime = kCMTimeZero
        
        for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints {
            let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
            let timeRangeForCurrentSlice = CMTimeRangeMake(startTimeForCurrentSlice, durationOfCurrentSlice)
            
            do {
                try videoCompTrack.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
            } catch {}
            do {
                try audioCompTrack.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
            } catch {}
            
            
            if compError != nil {
                NSLog("error during composition: \(compError)")
                if let completion = completion {
                    completion(compError)
                }
            }
            
            accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
        }
        
        let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset)
        exportSession!.outputURL = destinationURL as URL
        exportSession!.outputFileType = AVFileTypeMPEG4
        exportSession!.shouldOptimizeForNetworkUse = true
        
        removeFileAtURLIfExists(url: destinationURL)
        
        exportSession!.exportAsynchronously(completionHandler: { () -> Void in
            if let completion = completion {
                completion(exportSession!.error as NSError?)
            }
        })
    } else {
        NSLog("Could not find a suitable export preset for the input video")
        let error = NSError(domain: "", code: -1, userInfo: nil)
        if let completion = completion {
            completion(error)
        }
    }
}

//----------------------------------------------------------------------------------------------//

@available(OSX 10.11, *)
func cropVideo(sourceURL: NSURL, statTime:Float, endTime:Float, milliseconds: Int)
{
    
    
    //let sourceURL = NSURL(fileURLWithPath: "/Users/marcocruz/Desktop/XCode/TV/Portugal-vs-Sweden-Mobile.mp4")
    let destinationURL = NSURL(fileURLWithPath: "/Library/WebServer/Documents/Portugal-Sweden/testeVideo\(milliseconds).mp4")
    
    /*let manager = NSFileManager.defaultManager()
    
    guard let documentDirectory = try? manager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true) else {return}
    guard let mediaType = "mp4" as? String else {return}
    guard let url = sourceURL1 as? NSURL else {return}*/
    
    if (true)/*mediaType == kUTTypeMovie as String || mediaType == "mp4" as String*/ {
        let asset = AVAsset(url: sourceURL as URL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        let start = statTime
        let end = endTime
        
        
        
        //Remove existing file
        removeFileAtURLIfExists(url: destinationURL)
        
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {return}
        exportSession.outputURL = destinationURL as URL
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.shouldOptimizeForNetworkUse = true
        
        let startTime = CMTime(seconds: Double(start ?? 0), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(end ?? length), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously{
            switch exportSession.status {
            case .completed:
                print("exported at \(destinationURL)")
                //self.saveVideoTimeline(outputURL)
            case .failed:
                print("failed \(exportSession.error)")
                
            case .cancelled:
                print("cancelled \(exportSession.error)")
                
            default: break
            }
        }
    }
}


extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
