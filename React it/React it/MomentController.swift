//
//  MomentController.swift
//  ClientPhoneApplication
//
//  Created by Marco Cruz on 14/08/16.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Charts
import Alamofire

class MomentController: UIViewController, UITableViewDataSource, NSURLConnectionDelegate {
    
    var playerView : AVPlayer!
    var playerViewController : AVPlayerViewController!
    
    var match_info = String()
    var reactions: Int!
    var moment = String()
    var milliseconds: Int!
    var author = String()
    var moment_id: Int!
    var home_team: String!
    var visitor_team: String!
    var from_controller: String!
    var chartAnimate:Bool = true
    
    weak var timer: Timer?
    weak var timerTable: Timer?
    
    var videoTimer = Timer()
    var videoState: Int! = 0
    
    @IBOutlet weak var btnGlobal: UIButton!
    @IBOutlet weak var btnFriends: UIButton!
    @IBOutlet weak var friends_label: UILabel!
    @IBOutlet weak var worldwide_label: UILabel!
    
    @IBAction func btnFriends(_ sender: Any) {
        if(self.openSubView != "friends"){
            self.openSubView = "friends"
            self.btnFriends.alpha = 1
            self.friends_label.alpha = 1
            self.btnGlobal.alpha = 0.3
            self.worldwide_label.alpha = 0.3
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.chartData), userInfo: nil, repeats: true);
            self.chartAnimate = true
            chartData()
            
        }
    }
    
    @IBAction func btnGlobal(_ sender: Any) {
        if(self.openSubView != "global"){
            self.openSubView = "global"
            self.btnFriends.alpha = 0.3
            self.friends_label.alpha = 0.3
            self.btnGlobal.alpha = 1
            self.worldwide_label.alpha = 1
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.chartData), userInfo: nil, repeats: true);
            self.chartAnimate = true
            chartData()
        }
    }

    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgViewVisitorTeam: UIImageView!
    @IBOutlet weak var imgViewHomeTeam: UIImageView!
    @IBOutlet weak var imageViewBG: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var labelMatchInfo: UILabel!
    @IBOutlet weak var labelMoment: UILabel!
    @IBOutlet weak var labelAuthor: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var PieChartView: PieChartView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var opinionsEmotionsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var opinionsEmotionsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelNumberAnswers: UILabel!
    @IBOutlet weak var labelFriends: UILabel!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    weak var valueFormatDelegate: IValueFormatter?
    //wear var sllDelegate: URLSessionDelegate?
    
    var openView:String!
    var openSubView:String!
    var momentData = [[String]]()
    var opinionsData = Dictionary<String, Double>()
    var emotionsData = Dictionary<String, Double>()
    
    var totalAnswersAux:Double! = 1
    
    func setChart(){
        
        if(self.openView == "opinions"){
            
            PieChartView.isHidden = false
            barChartView.isHidden = true
            
            PieChartView.noDataText = "Couldn't retrieve data from server."
            var values = [opinionsData["up"], opinionsData["down"]]
            
            PieChartView.drawHoleEnabled = false
            
            var dataEntries: [PieChartDataEntry] = []
            
            for i in 0..<2 {
                let dataEntry = PieChartDataEntry(value: values[i]! / self.totalAnswersAux)
                if(i == 0){
                    if(values[i] != 0.0){
                        dataEntry.label = "👍🏼"
                    }
                }else{
                    if(values[i] != 0.0){
                        dataEntry.label = "👎🏼"
                    }
                }
                
                dataEntries.append(dataEntry)
            }
            let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
            
            
            var colors: [UIColor] = []
            
            let color1 = UIColor(red: 0/255.0, green: 190/255.0, blue: 0/255.0, alpha: 0.5)
            let color2 = UIColor(red: 190/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
            
            colors.append(color1)
            colors.append(color2)
            chartDataSet.colors = colors
            
            
            let chartData = PieChartData(dataSet: chartDataSet)
            PieChartView.data = chartData

            
            chartDataSet.valueFormatter = valueFormatDelegate
            chartDataSet.valueFont = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightLight)
            chartDataSet.sliceSpace = 3
            
            if(chartAnimate){
                PieChartView.animate(yAxisDuration: 1.0, easingOption: ChartEasingOption.easeInCubic)
            }

            self.chartAnimate = false
            
            PieChartView.chartDescription?.text = ""
            let chartLegend = PieChartView.legend
            chartLegend.enabled = false
            
        }else{
            
            PieChartView.isHidden = true
            barChartView.isHidden = false
            barChartView.noDataText = "No data."
            var values = [emotionsData["connected"], emotionsData["elation"], emotionsData["surprise"], emotionsData["worry"], emotionsData["unhappy"], emotionsData["angry"]]
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<6 {
                let dataEntry = BarChartDataEntry(x: Double(i+10), y: values[i]! / self.totalAnswersAux )
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Reactions")
            let color1 = UIColor(red: 98/255.0, green: 255/255.0, blue: 0/255.0, alpha: 0.5)
            let color2 = UIColor(red: 255/255.0, green: 238/255.0, blue: 0/255.0, alpha: 0.5)
            let color3 = UIColor(red: 0/255.0, green: 183/255.0, blue: 255/255.0, alpha: 0.5)
            let color4 = UIColor(red: 28/255.0, green: 136/255.0, blue: 21/255.0, alpha: 0.5)
            let color5 = UIColor(red: 0/255.0, green: 119/255.0, blue: 224/255.0, alpha: 0.5)
            let color6 = UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
            chartDataSet.colors = [color1, color2, color3, color4, color5, color6]
            chartDataSet.valueFont = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightLight)
            chartDataSet.valueFormatter = valueFormatDelegate
            let chartData = BarChartData(dataSet: chartDataSet)
            chartData.barWidth = 0.6
            barChartView.data = chartData
            barChartView.xAxis.labelPosition = .bottom
            if(chartAnimate){
                barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
            }
            barChartView.drawBarShadowEnabled = false;
            barChartView.drawValueAboveBarEnabled = true;
            barChartView.maxVisibleCount = 100;
            barChartView.chartDescription?.text = ""
            let xAxis = barChartView.xAxis
            xAxis.valueFormatter = axisFormatDelegate
            xAxis.drawGridLinesEnabled = false;
            xAxis.labelFont = UIFont.systemFont(ofSize: 30.0, weight: UIFontWeightLight)
            let leftAxis = barChartView.leftAxis
            leftAxis.labelCount = 2;
            leftAxis.axisMinimum = 0.0;
            leftAxis.enabled=false
            leftAxis.granularityEnabled = true
            leftAxis.granularity = 1.0
            let rightAxis = barChartView.rightAxis
            rightAxis.enabled = false
            let chartLegend = barChartView.legend
            chartLegend.enabled = false
            self.chartAnimate = false
        }
        
    }
    
    func initDictionaries()
    {
        opinionsData.updateValue(0.0, forKey: "up")
        opinionsData.updateValue(0.0, forKey: "down")
    
        emotionsData.updateValue(0.0, forKey: "connected")
        emotionsData.updateValue(0.0, forKey: "elation")
        emotionsData.updateValue(0.0, forKey: "surprise")
        emotionsData.updateValue(0.0, forKey: "worry")
        emotionsData.updateValue(0.0, forKey: "unhappy")
        emotionsData.updateValue(0.0, forKey: "angry")
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if(self.from_controller == "Notification Response Controller"){
            if parent == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var vc = storyboard.instantiateViewController(withIdentifier: "MainController") as! UITabBarController
            UIApplication.shared.keyWindow?.rootViewController = vc
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.btnFriends.layer.zPosition = 100
        self.btnGlobal.layer.zPosition = 100
        
        self.btnPlay.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.40).cgColor
        self.btnPlay.layer.shadowOpacity = 0.8
        self.btnPlay.layer.shadowRadius = 2.0
        self.btnPlay.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        let attr = NSDictionary(object: UIFont(name: "Avenir Next", size: 14.0)!, forKey: NSFontAttributeName as NSCopying)
        self.segmentControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        self.segmentControl.layer.cornerRadius = 4.0
        self.segmentControl.layer.borderColor = UIColor(red: 235, green: 235, blue: 241, alpha: 1.0).cgColor
        self.segmentControl.layer.borderWidth = 1.0
        self.segmentControl.layer.masksToBounds = true;
        
        if(self.from_controller == "Moments Controller"){
            var navArray:Array = (self.navigationController?.viewControllers)!
            navArray.remove(at: navArray.count-2)
            navArray.remove(at: navArray.count-2)
            self.navigationController?.viewControllers = navArray
        }
       
        imageViewBG.addBlurEffect()
        topView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.40).cgColor
        topView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        topView.layer.shadowOpacity = 1.0
        topView.layer.shadowRadius = 4.0
        topView.layer.cornerRadius = 5.0
        imgViewHomeTeam.image = UIImage(named:"\(home_team!)-flag.png")
        imgViewVisitorTeam.image = UIImage(named:"\(visitor_team!)-flag.png")
        
        axisFormatDelegate = self
        valueFormatDelegate = self
        //sslDelegate = self
        self.openView = "opinions"
        self.openSubView = "friends"
        
        initDictionaries()
        
        chartData()
        tableData()
        
        setChart() //have to set chart again due to a view bug
        auxSetChartEmotions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //self.tabBarController?.tabBar.isHidden = true
        labelMatchInfo.text = match_info
        labelMoment.text = moment
        if(reactions == 1){
            labelAuthor.text = "\(reactions!) friend reaction"
        }else{
            labelAuthor.text = "\(reactions!) friends reactions"
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.chartData), userInfo: nil, repeats: true);
        self.timerTable = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.tableData), userInfo: nil, repeats: true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timer?.invalidate()
        self.timerTable?.invalidate()
    }

    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    @IBAction func indexChanged(_ sender: UISegmentedControl)
    {
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            self.openView = "opinions"
            self.labelFriends.text = "FRIENDS' OPINIONS"
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.chartData), userInfo: nil, repeats: true);
            self.chartAnimate = true
            chartData()
            tableData()
        case 1:
            self.openView = "emotions"
            self.labelFriends.text = "FRIENDS' EMOTIONS"
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.chartData), userInfo: nil, repeats: true);
            self.chartAnimate = true
            chartData()
            tableData()
        default:
            break;
        }
    }
    
    func chartData()
    {
        print("update data")
        
        if(openView == "opinions" && openSubView == "friends"){
            Alamofire.request("\(globalvariable.server!)/opinions", method: .get, parameters: ["momentid": self.moment_id]).responseJSON { response in
                //print(response)
                //to get status code
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
                                self.opinionsData.updateValue(Double(JSON[i]["number"]!)!, forKey: JSON[i]["opinion"]!)
                                n = n + Double(JSON[i]["number"]!)!
                            }
                            self.totalAnswersAux = n
                        }
                        if( Int(n) == 1 ){
                            self.labelAuthor.text = "\(Int(n)) friend reaction"
                        }else{
                            self.labelAuthor.text = "\(Int(n)) friends reactions"
                        }
                        self.setChart()
                    default:
                        self.opinionsData.removeAll()
                        print("error with response status: \(status)")
                    }
                }
            }

        }else if(openView == "emotions" && openSubView == "friends"){
            Alamofire.request("\(globalvariable.server!)/emotions", method: .get, parameters: ["momentid": self.moment_id]).responseJSON { response in
                //print(response)
                //to get status code
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
                                self.emotionsData.updateValue(Double(JSON[i]["number"]!)!, forKey: JSON[i]["emotion"]!)
                                n = n + Double(JSON[i]["number"]!)!
                            }
                            self.totalAnswersAux = n
                        }
                        if( Int(n) == 1 ){
                            self.labelAuthor.text = "\(Int(n)) friend reaction"
                        }else{
                            self.labelAuthor.text = "\(Int(n)) friends reactions"
                        }
                        self.setChart()
                    default:
                        self.emotionsData.removeAll()
                        print("error with response status: \(status)")
                    }
                }
            }
        }else if(openView == "opinions" && openSubView == "global"){
            Alamofire.request("\(globalvariable.server!)/opinionsworldwide", method: .get, parameters: ["momentid": self.moment_id, "time": self.milliseconds]).responseJSON { response in
                //print(response)
                //to get status code
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
                                self.opinionsData.updateValue(Double(JSON[i]["number"]!)!, forKey: JSON[i]["opinion"]!)
                                n = n + Double(JSON[i]["number"]!)!
                            }
                            self.totalAnswersAux = n
                        }
                        if( Int(n) == 1 ){
                            self.labelAuthor.text = "\(Int(n)) worldwide reaction"
                        }else{
                            self.labelAuthor.text = "\(Int(n)) worldwide reactions"
                        }
                        self.setChart()
                    default:
                        self.opinionsData.removeAll()
                        print("error with response status: \(status)")
                    }
                }
            }
        }else{
            Alamofire.request("\(globalvariable.server!)/emotionsworldwide", method: .get, parameters: ["momentid": self.moment_id, "time": self.milliseconds]).responseJSON { response in
                //print(response)
                //to get status code
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
                                self.emotionsData.updateValue(Double(JSON[i]["number"]!)!, forKey: JSON[i]["emotion"]!)
                                n = n + Double(JSON[i]["number"]!)!
                            }
                            self.totalAnswersAux = n
                        }
                        if( Int(n) == 1 ){
                            self.labelAuthor.text = "\(Int(n)) worldwide reaction"
                        }else{
                            self.labelAuthor.text = "\(Int(n)) worldwide reactions"
                        }
                        self.setChart()
                    default:
                        self.emotionsData.removeAll()
                        print("error with response status: \(status)")
                    }
                }
            }
        }
    }
    
    func tableData()
    {
        
        Alamofire.request("\(globalvariable.server!)/responses", method: .get, parameters: ["momentid": self.moment_id]).responseJSON { response in
            //print(response)
            //to get status code
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    self.momentData.removeAll()
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            //["name", "opinion", "emotion"]
                            self.momentData.append(["\(JSON[i]["first_name"]!) \(JSON[i]["last_name"]!)", JSON[i]["opinion"]!, JSON[i]["emotion"]!, JSON[i]["avatar"]!])
                        }
                    }
                    self.tableView.dataSource = self
                    self.tableView.tableFooterView = UIView()
                    self.tableView.reloadData()
                    self.scrollViewHeight.constant = CGFloat(346 + 50 * self.momentData.count)
                    self.contentViewHeight.constant = CGFloat(346 + 50 * self.momentData.count)
                    self.opinionsEmotionsViewHeight.constant = CGFloat(346 + 50 * self.momentData.count)
                    self.opinionsEmotionsTableViewHeight.constant = self.tableView.contentSize.height
                default:
                    self.momentData.removeAll()
                    self.tableView.reloadData()
                    print("error with response status: \(status)")
                }
            }
        }
    }
    
    
    /////////////////////////////////////// TABLE ///////////////////////////////////////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.momentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpinionsEmotionsCell", for: indexPath) as! OpinionsEmotionsTableCell
        let row = (indexPath as NSIndexPath).row
        cell.viewAvatar.image = UIImage(named:"\(self.momentData[row][3]).png")
        cell.labelName.text = self.momentData[row][0]
        if(self.openView == "opinions"){
            if(self.momentData[row][1] == "up"){
                cell.labelOpinionEmotion.text = "👍🏼"
            }else{
                cell.labelOpinionEmotion.text = "👎🏼"
            }
        }else{
            if(self.momentData[row][2] == "connected"){
                cell.labelOpinionEmotion.text = "👏🏼"
            }else if(self.momentData[row][2] == "elation"){
                cell.labelOpinionEmotion.text = "😀"
            }else if(self.momentData[row][2] == "worry"){
                cell.labelOpinionEmotion.text = "😨"
            }else if(self.momentData[row][2] == "surprise"){
                cell.labelOpinionEmotion.text = "😮"
            }else if(self.momentData[row][2] == "unhappy"){
                cell.labelOpinionEmotion.text = "😔"
            }else{
                cell.labelOpinionEmotion.text = "😠"
            }
            
        }
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        return cell
    }
    
    
    /////////////////////////////////////// VIDEO ///////////////////////////////////////
    
    
    fileprivate func convertTime() -> Int{
        let time = self.moment
        let timeArr = time.characters.split{$0 == ":"}.map(String.init)
        let milliseconds = Int(timeArr[0])! * 60000 + Int(timeArr[1])! * 1000
        
        return milliseconds;
    }
    
    @IBAction func playVideo(_ sender: UIButton)
    {

            let videoImageUrl = "\(globalvariable.server!)/video.mp4?milliseconds=\(self.milliseconds!)"
            let url = URL(string: videoImageUrl);
            let urlData = try? Data(contentsOf: url!);
            
            if(urlData != nil)
            {
                if Platform.isSimulator {
                    //Running on simulator
                    print("running on simulator")
                    
                    let filePath = "/Users/marcocruz/Desktop/XCode/React it/Video.mp4"
                    
                    DispatchQueue.main.async(execute: {
                        try? urlData?.write(to: URL(fileURLWithPath: filePath), options: [.atomic]);
                        var fileURL: URL!
                        fileURL = URL(fileURLWithPath: "/Users/marcocruz/Desktop/XCode/React it/Video.mp4")
                        
                        self.playerView = AVPlayer(url: fileURL)
                        self.playerViewController = AVPlayerViewController()
                        self.playerViewController.player = self.playerView
                        self.present(self.playerViewController, animated: true){
                            self.playerViewController.player?.play()
                        }
                        
                        NotificationCenter.default.addObserver(self, selector: #selector(MomentController.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerView.currentItem)
                    })
                    
                }else{
                    //Running on iPhone
                    print("running on iphone")
                    
                    let file = "Video.mp4"
                    let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
                    let dir = dirs[0]; //documents
                    let filePath = URL(fileURLWithPath: dir).appendingPathComponent(file)
                    
                    
                    
                    DispatchQueue.main.async(execute: {
                        try? urlData?.write(to: filePath, options: [.atomic]);
                        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
                        
                        self.playerView = AVPlayer(url: filePath)
                        self.playerViewController = AVPlayerViewController()
                        self.playerViewController.player = self.playerView
                        self.present(self.playerViewController, animated: true){
                            self.playerViewController.player?.play()
                        }
                        
                        NotificationCenter.default.addObserver(self, selector: #selector(MomentController.playerDidFinishPlaying),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerView.currentItem)
                        
                        self.videoTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.checkVideoState), userInfo: nil, repeats: true);
                    })
                }
            }
    }
    
    func playerDidFinishPlaying(){
        self.videoState = 0
        self.videoTimer.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    func checkVideoState(){
        if (self.playerViewController.player?.rate == 0 && self.playerViewController.isBeingDismissed && self.videoState == 1) {
            self.videoState = 0
            self.videoTimer.invalidate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func auxSetChartEmotions(){
        var values = [emotionsData["connected"], emotionsData["elation"], emotionsData["surprise"], emotionsData["worry"], emotionsData["unhappy"], emotionsData["angry"]]
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<6 {
            let dataEntry = BarChartDataEntry(x: Double(i+10), y: values[i]! / self.totalAnswersAux )
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Reactions")
        let color1 = UIColor(red: 98/255.0, green: 255/255.0, blue: 0/255.0, alpha: 0.5)
        let color2 = UIColor(red: 255/255.0, green: 238/255.0, blue: 0/255.0, alpha: 0.5)
        let color3 = UIColor(red: 0/255.0, green: 183/255.0, blue: 255/255.0, alpha: 0.5)
        let color4 = UIColor(red: 28/255.0, green: 136/255.0, blue: 21/255.0, alpha: 0.5)
        let color5 = UIColor(red: 0/255.0, green: 119/255.0, blue: 224/255.0, alpha: 0.5)
        let color6 = UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        chartDataSet.colors = [color1, color2, color3, color4, color5, color6]
        chartDataSet.valueFont = UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightLight)
        chartDataSet.valueFormatter = valueFormatDelegate
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.6
        barChartView.data = chartData
        barChartView.xAxis.labelPosition = .bottom
        if(chartAnimate){
            barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .linear)
        }
        barChartView.drawBarShadowEnabled = false;
        barChartView.drawValueAboveBarEnabled = true;
        barChartView.maxVisibleCount = 100;
        barChartView.chartDescription?.text = ""
        let xAxis = barChartView.xAxis
        xAxis.valueFormatter = axisFormatDelegate
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelFont = UIFont.systemFont(ofSize: 30.0, weight: UIFontWeightLight)
        let leftAxis = barChartView.leftAxis
        leftAxis.labelCount = 2;
        leftAxis.axisMinimum = 0.0;
        leftAxis.enabled=false
        leftAxis.granularityEnabled = true
        leftAxis.granularity = 1.0
        let rightAxis = barChartView.rightAxis
        rightAxis.enabled = false
        let chartLegend = barChartView.legend
        chartLegend.enabled = false
        self.chartAnimate = false
    }
    
}

extension MomentController: IValueFormatter, IAxisValueFormatter, URLSessionDelegate{
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if(self.openView == "opinions"){
            if(value == 0.0){
                return ""
            }else{
                return "\(Int(round(value*100)))%"
            }
            
        }else{
            return "\(Int(round(value*100)))%"
        }
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var output:String
        switch(value){
        case 0: output = "👍🏼"
        case 1: output = "👎🏼"
        case 10: output = "👏🏼"
        case 11: output = "😀"
        case 12: output = "😮"
        case 13: output = "😨"
        case 14: output = "😔"
        case 15: output = "😠"
        default: output = ""
        }
        return output
    }
}

extension NSURLRequest {
    static func allowsAnyHTTPSCertificateForHost(host: String) -> Bool {
        return true
    }
}
