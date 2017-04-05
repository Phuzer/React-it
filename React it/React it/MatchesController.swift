//
//  MatchesController.swift
//  OpinionSharePhone
//
//  Created by Marco Cruz on 08/11/2016.
//  Copyright © 2016 Marco Cruz. All rights reserved.
//

import UIKit
import Alamofire

class MatchesController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loading_view: UIView!
    
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    var matchesInfo = [[String]]()
    let textCellIdentifier = "MatchesCell"
    
    weak var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func do_table_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.timer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(self.update), userInfo: nil, repeats: true);
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.matchesInfo.removeAll()
        self.tableView.reloadData()
        self.setLoadingScreen()
        self.loadData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timer?.invalidate()
    }
    
    
    func update(){
        Alamofire.request("\(globalvariable.server!)/matches").responseJSON { response in
            //print(response)
            //to get status code
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    self.matchesInfo.removeAll()
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            //["match_id", "match_info", "match_moments", "match_status", "home", "visitor"]
                            self.matchesInfo.append(["\(JSON[i]["match_id"]!)", "\(JSON[i]["home"]!) \(JSON[i]["home_score"]!) - \(JSON[i]["visitor_score"]!) \(JSON[i]["visitor"]!)", "\(JSON[i]["moment_count"]!)", "\(JSON[i]["status"]!)", JSON[i]["home"]!, JSON[i]["visitor"]!])
                        }
                    }
                default:
                    //self.matchesInfo.removeAll()
                    print("error with response status: \(status)")
                }
            }
            self.tableView.reloadData()
            self.tableView.separatorStyle = .singleLine
            
        }
        self.do_table_refresh();
        print("Updated table Matches")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchesInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! MatchesTableCell
        let row = (indexPath as NSIndexPath).row
        
        cell.labelTeams.text = matchesInfo[row][1]
        
        if(matchesInfo[row][2] == "1"){
            cell.labelMoments.text = "\(matchesInfo[row][2]) moment"
        }else{
            cell.labelMoments.text = "\(matchesInfo[row][2]) moments"
        }
        
        cell.imgViewHomeTeam.image = UIImage(named:"\(matchesInfo[row][4])-flag.png")
        cell.imgViewVisitorTeam.image = UIImage(named:"\(matchesInfo[row][5])-flag.png")
        
        if(matchesInfo[row][3] == "Live"){
            cell.labelGameStatus.textColor = UIColor(red: 0/255.0, green: 190/255.0, blue: 0/255.0, alpha: 1.0)

        }else{
            cell.labelGameStatus.textColor = UIColor(red: 190/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        }
        cell.labelGameStatus.text = matchesInfo[row][3]
        
        let userDefaults = UserDefaults.standard
        var count = userDefaults.integer(forKey: "notificationCount")
        
        if(count != 0 && row == 0){
            cell.notificationNumber.text = "\(count)"
            cell.notificationNumber.layer.cornerRadius = 10;
            cell.notificationNumber.layer.masksToBounds = true;
            cell.notificationNumber.backgroundColor = UIColor.red
            cell.notificationNumber.textColor = UIColor.white
        }else{
            cell.notificationNumber.backgroundColor = UIColor.white
            cell.notificationNumber.textColor = UIColor.white
        }
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    fileprivate func loadData()
    {
        Alamofire.request("\(globalvariable.server!)/matches").responseJSON { response in
            //print(response)
            //to get status code
            if let status = response.response?.statusCode {
                switch(status){
                case 201:
                    self.matchesInfo.removeAll()
                    if let result = response.result.value {
                        let JSON = result as! Array<Dictionary<String,String>>
                        for i in 0..<JSON.count{
                            //["match_id", "match_info", "match_moments", "match_status", "home", "visitor"]
                            self.matchesInfo.append(["\(JSON[i]["match_id"]!)", "\(JSON[i]["home"]!) \(JSON[i]["home_score"]!) - \(JSON[i]["visitor_score"]!) \(JSON[i]["visitor"]!)", "\(JSON[i]["moment_count"]!)", "\(JSON[i]["status"]!)", JSON[i]["home"]!, JSON[i]["visitor"]!])
                        }
                    }
                default:
                    self.matchesInfo.removeAll()
                    print("error with response status: \(status)")
                }
            }
            self.tableView.reloadData()
            self.tableView.separatorStyle = .singleLine
            self.removeLoadingScreen()
        }
        self.do_table_refresh();
    }
    
    // Set the activity indicator into the main view
    fileprivate func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let x = (screenWidth / 2) - (width / 2)
        let y = (screenHeight / 2) - (height / 2) - 80  //(self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        self.loadingLabel.isHidden = false
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.loading_view.addSubview(loadingView)
        self.loading_view.isHidden = false
    }
    
    // Remove the activity indicator from the main view
    fileprivate func removeLoadingScreen() {
        // Hides and stops the text and the spinner
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
        self.loading_view.isHidden = true
        
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "momentsSegue"){
            let DestViewController : MomentsController = segue.destination as! MomentsController
            let itemIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
            DestViewController.match_id = Int(self.matchesInfo[itemIndex!][0])
            DestViewController.match_info = self.matchesInfo[itemIndex!][1]
            DestViewController.home_team = self.matchesInfo[itemIndex!][4]
            DestViewController.visitor_team = self.matchesInfo[itemIndex!][5]
        }else{
            let DestViewController : MomentsController = segue.destination as! MomentsController
            DestViewController.match_id = 1
            DestViewController.match_info = "Sweden 1 - 1 Portugal"
            DestViewController.home_team = "Sweden"
            DestViewController.visitor_team = "Portugal"
        }
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
