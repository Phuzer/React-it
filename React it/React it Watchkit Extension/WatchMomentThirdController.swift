//
//  WatchMomentThirdController.swift
//  OpinionShareWatch
//
//  Created by Marco Cruz on 11/12/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire

class WatchMomentThirdController: WKInterfaceController {
    
    
    @IBOutlet var label_emotions: WKInterfaceLabel!
    @IBOutlet var bar_emotion1: WKInterfaceGroup!
    @IBOutlet var bar_emotion2: WKInterfaceGroup!
    @IBOutlet var bar_emotion3: WKInterfaceGroup!
    @IBOutlet var bar_emotion4: WKInterfaceGroup!
    @IBOutlet var bar_emotion5: WKInterfaceGroup!
    @IBOutlet var bar_emotion6: WKInterfaceGroup!
    @IBOutlet var label_emotion1: WKInterfaceLabel!
    @IBOutlet var label_emotion2: WKInterfaceLabel!
    @IBOutlet var label_emotion3: WKInterfaceLabel!
    @IBOutlet var label_emotion4: WKInterfaceLabel!
    @IBOutlet var label_emotion5: WKInterfaceLabel!
    @IBOutlet var label_emotion6: WKInterfaceLabel!
    @IBOutlet var back_emotion1: WKInterfaceGroup!
    @IBOutlet var back_emotion2: WKInterfaceGroup!
    @IBOutlet var back_emotion3: WKInterfaceGroup!
    @IBOutlet var back_emotion4: WKInterfaceGroup!
    @IBOutlet var back_emotion5: WKInterfaceGroup!
    @IBOutlet var back_emotion6: WKInterfaceGroup!
    
    
    var moment_id: Int!
    var emotionsData = Dictionary<String, Double>()
    var totalEmotionsAux:Double! = 1
    
    var maxSizeBar:Double = 93.0
    var maxVal:Double = -1

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let moment_id = context as? Int {
            self.moment_id = moment_id
        }
        
        initDictionaries()
        chartEmotionsData()
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
        emotionsData.updateValue(0.0, forKey: "connected")
        emotionsData.updateValue(0.0, forKey: "elation")
        emotionsData.updateValue(0.0, forKey: "surprise")
        emotionsData.updateValue(0.0, forKey: "worry")
        emotionsData.updateValue(0.0, forKey: "unhappy")
        emotionsData.updateValue(0.0, forKey: "angry")
    }
    
    func chartEmotionsData()
    {
        Alamofire.request("\(globalvariable.server!)/emotions", method: .get, parameters: ["momentid": self.moment_id]).responseJSON { response in
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    self.emotionsData.removeAll()
                    self.initDictionaries()
                    var n:Double! = 0
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            //["opinion", "number"]
                            var number:Double = Double(JSON[i]["number"]!)!
                            self.emotionsData.updateValue(Double(JSON[i]["number"]!)!, forKey: JSON[i]["emotion"]!)
                            
                            if(self.maxVal < number){
                                self.maxVal = number
                            }
                            n = n + number
                        }
                        self.totalEmotionsAux = n
                    }
                    if( Int(n) == 1 ){
                        self.label_emotions.setText("\(Int(n)) emotion")
                    }else{
                        self.label_emotions.setText("\(Int(n)) emotions")
                    }
                    self.setChartEmotions()
                default:
                    self.emotionsData.removeAll()
                    print("error with response status: \(status)")
                }
            }
        }
    }
    
    
    
    func setChartEmotions()
    {
        let val1 = emotionsData["connected"]! / self.totalEmotionsAux
        label_emotion1.setText("\(Int(round(val1*100)))%")
        var size = Int(emotionsData["connected"]!*self.maxSizeBar/self.maxVal)
        bar_emotion1.setHeight( CGFloat(size) )
        back_emotion1.setHeight( CGFloat(size) )
        
        let val2 = emotionsData["elation"]! / self.totalEmotionsAux
        label_emotion2.setText("\(Int(round(val2*100)))%")
        size = Int(emotionsData["elation"]!*self.maxSizeBar/self.maxVal)
        bar_emotion2.setHeight( CGFloat(size) )
        back_emotion2.setHeight( CGFloat(size) )
        
        let val3 = emotionsData["surprise"]! / self.totalEmotionsAux
        label_emotion3.setText("\(Int(round(val3*100)))%")
        size = Int(emotionsData["surprise"]!*self.maxSizeBar/self.maxVal)
        bar_emotion3.setHeight( CGFloat(size) )
        back_emotion3.setHeight( CGFloat(size) )
        
        let val4 = emotionsData["worry"]! / self.totalEmotionsAux
        label_emotion4.setText("\(Int(round(val4*100)))%")
        size = Int(emotionsData["worry"]!*self.maxSizeBar/self.maxVal)
        bar_emotion4.setHeight( CGFloat(size) )
        back_emotion4.setHeight( CGFloat(size) )
        
        let val5 = emotionsData["unhappy"]! / self.totalEmotionsAux
        label_emotion5.setText("\(Int(round(val5*100)))%")
        size = Int(emotionsData["unhappy"]!*self.maxSizeBar/self.maxVal)
        bar_emotion5.setHeight( CGFloat(size) )
        back_emotion5.setHeight( CGFloat(size) )
        
        let val6 = emotionsData["angry"]! / self.totalEmotionsAux
        label_emotion6.setText("\(Int(round(val6*100)))%")
        size = Int(emotionsData["angry"]!*self.maxSizeBar/self.maxVal)
        bar_emotion6.setHeight( CGFloat(size) )
        back_emotion6.setHeight( CGFloat(size) )
    }

}
