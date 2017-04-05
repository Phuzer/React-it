//
//  ViewController.swift
//  Video generator
//
//  Created by Marco Cruz on 03/02/2017.
//  Copyright © 2017 Marco Cruz. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    typealias TrimCompletion = (NSError?) -> ()
    typealias TrimPoints = [(CMTime, CMTime)]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var totalMilliseconds = 735000
        var milliseconds = 701000
        while(milliseconds <= totalMilliseconds){
            saveVideo(milliseconds: milliseconds)
            
            milliseconds = milliseconds + 1000
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    func saveVideo(milliseconds: Int)
    {
        typealias TrimCompletion = (NSError?) -> ()
        typealias TrimPoints = [(CMTime, CMTime)]
        
        //let sourceURL = NSURL(fileURLWithPath: "/Users/marcocruz/Desktop/XCode/TV/Sweden-Portugal.mp4")
        //let destinationURL = NSURL(fileURLWithPath: "/Library/WebServer/Documents/Portugal-Sweden/Video\(milliseconds).mp4")
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
        
        
        let backgroundQueueWatch = DispatchQueue(label: "com.app.queuetrimvideowatch",
                                                 qos: .background,
                                                 target: nil)
        backgroundQueueWatch.async{
            self.trimVideo(sourceURL: sourceURLWatch, destinationURL: destinationURLWatch, trimPoints: trimPoints) { error in
                if let error = error {
                    NSLog("Failure: \(error)")
                } else {
                    NSLog("Success")
                }
                
            }
        }
    }
    
    
    
    
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



}

