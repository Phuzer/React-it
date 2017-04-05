//
//  ViewController.swift
//  Thumbnail Generator
//
//  Created by Marco Cruz on 13/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        generateThumbnails()
        
    }
    
    func generateThumbnails(){
        let sourceURL = URL(fileURLWithPath: "/Users/marcocruz/Desktop/XCode/TV/Sweden-Portugal.mp4")
        let asset: AVAsset = AVAsset(url: sourceURL)
        var milliseconds = Int64(1000)
        let totalDuration = Int64(asset.duration.value)
        var count = 0
        while(milliseconds < totalDuration){
            let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time        : CMTime = CMTimeMake(milliseconds, 1000)
            let img         : CGImage
            do {
                try img = assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let frameImg: UIImage = UIImage(cgImage: img)
                let newImage: UIImage = resizeImage(frameImg)
                let filePath = "/Library/WebServer/Documents/Thumbnails-Portugal-Sweden/\(milliseconds).jpeg"
                try? UIImageJPEGRepresentation(newImage, 1.0)!.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
            } catch { }
            milliseconds = milliseconds + 1000
            count = count + 1
        }
        print("Total \(count) images saved")
    }
    
    func resizeImage(_ image: UIImage) -> UIImage
    {
        let newWidth:CGFloat = 240
        let newHeight:CGFloat = 135
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
