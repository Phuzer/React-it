//
//  testeController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 23/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation


class testeController: WKInterfaceController {

    @IBOutlet var inlineMovie :WKInterfaceInlineMovie!
    @IBOutlet var tapGestureRecognizer :WKTapGestureRecognizer!
    var playingInlineMovie :Bool = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        //let path = URL(fileURLWithPath: "/Library/WebServer/Documents/Portugal-Sweden/Video23000.mp4")
        
        //inlineMovie.setMovieURL(path)
        //inlineMovie.pause()
        
        playingInlineMovie = false
        //inlineMovie.setVideoGravity(WKVideoGravity(rawValue: WKVideoGravity.resizeAspectFill.rawValue)!)
    }

    @IBAction func btn1() {
        //inlineMovie.setVideoGravity(WKVideoGravity(rawValue: WKVideoGravity.resize.rawValue)!)
        let path = URL(fileURLWithPath: "/Library/WebServer/Documents/Portugal-Sweden/Video23000.mp4")
        inlineMovie.setMovieURL(path)
        inlineMovie.setVideoGravity(WKVideoGravity(rawValue: WKVideoGravity.resizeAspectFill.rawValue)!)
        inlineMovie.play()
    }
    @IBAction func btn2() {
        //inlineMovie.setVideoGravity(WKVideoGravity(rawValue: WKVideoGravity.resizeAspect.rawValue)!)
        inlineMovie.pause()
    }
    @IBAction func btn3() {
        //inlineMovie.setVideoGravity(WKVideoGravity(rawValue: WKVideoGravity.resizeAspectFill.rawValue)!)
        inlineMovie.playFromBeginning()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func tap(_ sender: Any) {
        if playingInlineMovie == false {
            print("playing")
            inlineMovie.play()
        } else {
            print("paused")
            inlineMovie.pause()
            
        }
        
        playingInlineMovie = !playingInlineMovie
    }
    
    func startVideo(path: URL){
        inlineMovie.setMovieURL(path)
        inlineMovie.play()
    }
    

}
