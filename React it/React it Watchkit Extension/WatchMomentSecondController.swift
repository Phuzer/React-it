//
//  WatchMomentSecondController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 11/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class WatchMomentSecondController: WKInterfaceController {
    
    
    @IBOutlet var label_opinions: WKInterfaceLabel!
    @IBOutlet var label_thumbsUp: WKInterfaceLabel!
    @IBOutlet var label_thumbsDown: WKInterfaceLabel!
    @IBOutlet var circularChart: WKInterfaceImage!
    
    
    var moment_id: Int!
    var opinionsData = Dictionary<String, Double>()
    var totalOpinionsAux:Double! = 1
    
    var maxSizeBar:Double = 93.0
    var maxVal:Double = -1

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let moment_id = context as? Int {
            self.moment_id = moment_id
        }
        
        initDictionaries()
        chartOpinionsData()
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

    func initDictionaries()
    {
        opinionsData.updateValue(0.0, forKey: "up")
        opinionsData.updateValue(0.0, forKey: "down")
    }
    
    func chartOpinionsData()
    {
        Alamofire.request("\(globalvariable.server!)/opinions", method: .get, parameters: ["momentid": self.moment_id]).responseJSON { response in
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    self.opinionsData.removeAll()
                    self.initDictionaries()
                    var n:Double! = 0
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            //["opinion", "number"]
                            var number:Double = Double(JSON[i]["number"]!)!
                            self.opinionsData.updateValue(number, forKey: JSON[i]["opinion"]!)
                            if(self.maxVal < number){
                                self.maxVal = number
                            }
                            n = n + number
                        }
                        self.totalOpinionsAux = n
                    }
                    if( Int(n) == 1 ){
                        self.label_opinions.setText("\(Int(n)) opinion")
                    }else{
                        self.label_opinions.setText("\(Int(n)) opinions")
                    }
                    self.setChartOpinions()
                default:
                    self.opinionsData.removeAll()
                    print("error with response status: \(status)")
                }
            }
            
        }
    }
    
    func setChartOpinions()
    {
        let thumbsUp = opinionsData["up"]! / self.totalOpinionsAux
        label_thumbsUp.setText("\(Int(round(thumbsUp*100)))%")
        
        let thumbsDown = opinionsData["down"]! / self.totalOpinionsAux
        label_thumbsDown.setText("\(Int(round(thumbsDown*100)))%")
        
        circularChart.setImageNamed("circular\(Int(round(thumbsDown*100)))pie")
        circularChart.setAlpha(0.75)
    }
    
}
