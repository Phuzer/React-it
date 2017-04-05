//
//  MonitoredMatchesController.swift
//  React it
//
//  Created by Marco Cruz on 09/01/2017.
//  Copyright © 2017 Marco Cruz. All rights reserved.
//

import UIKit
import Charts
import Alamofire

class MonitoredMatchesController: UIViewController , ChartViewDelegate{

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var label_min: UILabel!
    @IBOutlet weak var label_avg: UILabel!
    @IBOutlet weak var label_max: UILabel!
    @IBOutlet weak var topView: UIView!

    @IBOutlet weak var imgDisclosure: UIImageView!
    @IBOutlet weak var minutes: UILabel!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    weak var valueFormatDelegate: IValueFormatter?
    
    var toggle = 1
   
    var realTimers = [[Int]]()
    
    var heartrateData = [[String]]()
    var aux_max: Int!
    var aux_min: Int!

    func handleTap(_ sender: UITapGestureRecognizer) {
        if(toggle == 0){
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: {
                self.imgDisclosure.transform = self.imgDisclosure.transform.rotated(by: CGFloat(M_PI_2))
                    self.contentView.isHidden = false
            }, completion: nil)
            
            toggle = 1
        }else{
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut], animations: {
                self.imgDisclosure.transform = self.imgDisclosure.transform.rotated(by: CGFloat(-M_PI_2))
                self.contentView.isHidden = true
            }, completion: nil)
            
            toggle = 0
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.minutes.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        topView.addGestureRecognizer(tap)
        topView.isUserInteractionEnabled = true
        self.view.addSubview(topView)

        self.imgDisclosure.transform = self.imgDisclosure.transform.rotated(by: CGFloat(M_PI_2))

        //[video_time, real_time]
        realTimers.append([0,   0   ])
        realTimers.append([6,   0  ])
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
        
        axisFormatDelegate = self
        valueFormatDelegate = self
 
        chartData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setChart(heartrateValues: [(Int,Int)]) {
    
        var count = 0
        var max = 0
        var min = 1000000
        var sum = 0

        lineChartView.noDataText = "No data."
        print(heartrateValues)
        // 1 - creating an array of data entries
        var dataEntries : [ChartDataEntry] = []
        for i in 0..<heartrateValues.count {
            let dataEntry = ChartDataEntry(x: Double( heartrateValues[i].0*1000 ), y: Double( heartrateValues[i].1 ))
            print("\(heartrateValues[i].0*1000), \(heartrateValues[i].1)")
            dataEntries.append(dataEntry)
            
            if(heartrateValues[i].1 > max){
                max = heartrateValues[i].1
            }
            if(heartrateValues[i].1 < min){
                min = heartrateValues[i].1
            }
            
            sum = sum + heartrateValues[i].1
            count = count + 1
        }
        
        aux_max = max
        aux_min = min
        self.label_min.text = "\(min)"
        self.label_max.text = "\(max)"
        self.label_avg.text = "\(Int(sum/count))"
    
        // 2 - create a data set with our array
        let chartDataSet: LineChartDataSet = LineChartDataSet(values: dataEntries, label: "Reactions")
        chartDataSet.axisDependency = .left // Line will correlate with left axis values
        chartDataSet.setColor(UIColor.red) // our line's opacity is 50%
        chartDataSet.setCircleColor(UIColor.red) // our circle will be dark red
        chartDataSet.lineWidth = 1.0
        chartDataSet.circleRadius = 0.5 // the radius of the node circle
        chartDataSet.fillAlpha = 65 / 255.0
        chartDataSet.fillColor = UIColor.red
        chartDataSet.highlightColor = UIColor.white
        chartDataSet.drawCircleHoleEnabled = true
    
        chartDataSet.valueFormatter = valueFormatDelegate
        chartDataSet.mode = .horizontalBezier
        
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.maxVisibleCount = 140;
        
        let xAxis = lineChartView.xAxis
        xAxis.valueFormatter = axisFormatDelegate
        xAxis.drawGridLinesEnabled = false;
        xAxis.granularityEnabled = true
        xAxis.granularity = 1.0;
        xAxis.labelFont = UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightLight)
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = 735000
        
        let leftAxis = lineChartView.leftAxis
        leftAxis.axisMinimum = 50.0
        leftAxis.axisMaximum = 140.0
        leftAxis.enabled = true
        leftAxis.drawLabelsEnabled = true
        leftAxis.drawGridLinesEnabled = false
        
        let rightAxis = lineChartView.rightAxis
        rightAxis.enabled = true
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawGridLinesEnabled = false
        
        lineChartView.chartDescription?.text = ""
        let chartLegend = lineChartView.legend
        chartLegend.enabled = false

    }
    
    func chartData(){
        
        let userDefaults = UserDefaults.standard
        
        if (userDefaults.value(forKey: "heartrate") != nil){
        
            var heartrateValues: [[Int]] = userDefaults.value(forKey: "heartrate") as! [[Int]]
            
            var tupleHeartrateValues = [(Int, Int)]()
            
            for i in 0..<heartrateValues.count {
                tupleHeartrateValues.append( (heartrateValues[i][0] , heartrateValues[i][1]) )
            }
            
            let sortedHeartrateValues = tupleHeartrateValues.sorted { $0.0 < $1.0 }
            
            if(heartrateValues.count != 0){
                self.minutes.isHidden = false
                self.setChart(heartrateValues: sortedHeartrateValues)
            }else{
                self.label_min.text = "---"
                self.label_max.text = "---"
                self.label_avg.text = "---"
                self.lineChartView.noDataText = "No data."
            }
        }else{
            self.label_min.text = "---"
            self.label_max.text = "---"
            self.label_avg.text = "---"
            self.lineChartView.noDataText = "No data."
        }
    
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MonitoredMatchesController: IValueFormatter, IAxisValueFormatter{
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return ""
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        let timerInSeconds = Int(value/1000)
        
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
            if(timerInSeconds >= realTimers[index+1][0]){
                index = index + 1
            }
        }
        let difference = timerInSeconds - realTimers[index][0]
        var minutes = String( (realTimers[index][1] + difference) / 60)
        var seconds = String( (realTimers[index][1] + difference) % 60)
        
        if(seconds.characters.count == 1){
            seconds = "0\(seconds)"
        }
        if(minutes.characters.count == 1){
            minutes = "0\(minutes)"
        }
        let real_time = "\(minutes):\(seconds)"
        
        return "\(real_time)"
    }
}
