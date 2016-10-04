//
//  PermisosViewController.swift
//  BOLD
//
//  Created by admin on 6/14/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class PermisosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var orderButton: UIButton!

    
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var orderSubView: UIView!
    @IBOutlet weak var orderViewLCHeight: NSLayoutConstraint!
    @IBOutlet weak var orderChangeDateButton: UIButton!
    @IBOutlet weak var orderStatDateButton: UIButton!
    @IBOutlet weak var orderTypeButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var permisosData: [NSDictionary]?
    var page: Int = 0
    let pageItem : Int = 25
    var loading : Bool = false
    var loadMore : Bool = false
    var lastContentOffset: CGFloat = 0
    var animation : Bool = false
    var showOrderView: Bool = false
    var orderType: Int = 0  // Changed date: 0 - Start date: 1 - Type & Date: 2

    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationView.backgroundColor = bgNavigationColor
        self.orderSubView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.orderSubView.layer.cornerRadius = 5
        self.orderSubView.clipsToBounds = true
        self.orderView.backgroundColor = bgMainColor
        self.orderViewLCHeight.constant = 0
        self.view .layoutIfNeeded()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.page = 0
        self.orderType = 0
        self.loading = false
        self.loadMore = true
        
        self.setSelectedButton(self.orderChangeDateButton, value: true)
        self.setSelectedButton(self.orderStatDateButton, value: false)
        self.setSelectedButton(self.orderTypeButton, value: false)

        self.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackBtn(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("mainview1")
        sideMenuController()?.setContentViewController(destViewController)
    }

    @IBAction func orderButtonClick(sender: AnyObject) {
        
        self.showOrderView = !self.showOrderView
        
        let height = self.showOrderView == true ? 154.0 : 0.0 as CGFloat
        
        UIView .animateWithDuration(0.2, animations: {
            
            self.view.userInteractionEnabled = false
            self.orderViewLCHeight.constant = height
            self.view .layoutIfNeeded()
            
            }, completion: { (Bool) in
                self.view.userInteractionEnabled = true
        })
    }
    
    func setSelectedButton(button: UIButton, value: Bool) {
        if value == true {
            button.titleLabel!.font = UIFont.boldSystemFontOfSize(17)
        }
        else {
            button.titleLabel!.font = UIFont.systemFontOfSize(15)
        }
    }

    @IBAction func orderChangeDateButtonClick(sender: AnyObject) {
        
        if self.orderType != 0 {
            self.setSelectedButton(self.orderChangeDateButton, value: true)
            self.setSelectedButton(self.orderStatDateButton, value: false)
            self.setSelectedButton(self.orderTypeButton, value: false)
            
            self.orderType = 0
            self.hiddenOrderView()
            
            // Reload data
            self.page = 0
            self.loadData()
            
        }
        else {
            self.hiddenOrderView()
        }
    }
    
    @IBAction func orderStatDateButtonClick(sender: AnyObject) {
        if self.orderType != 1 {
            
            self.setSelectedButton(self.orderChangeDateButton, value: false)
            self.setSelectedButton(self.orderStatDateButton, value: true)
            self.setSelectedButton(self.orderTypeButton, value: false)
            
            self.hiddenOrderView()
            self.orderType = 1
            
            // Reload data
            self.page = 0
            self.loadData()

        }
        else {
            self.hiddenOrderView()
            
        }
        
    }
    
    @IBAction func orderTypeButtonClick(sender: AnyObject) {
        
        if self.orderType != 2 {
            
            self.setSelectedButton(self.orderChangeDateButton, value: false)
            self.setSelectedButton(self.orderStatDateButton, value: false)
            self.setSelectedButton(self.orderTypeButton, value: true)
            
            self.hiddenOrderView()
            self.orderType = 2
            
            // Reload data
            self.page = 0
            self.loadData()
        }
        else {
            self.hiddenOrderView()
        }
    }
    
    func hiddenOrderView() {
        self.orderButtonClick(0)
    }
    

    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func loadData() {
        
        if (self.loading == true || (self.page > 0 && self.loadMore == false)) {
            return;
        }
        
        if self.page == 0 {
            self.indicator .startAnimating()
        }

        self.loading = true
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/report", serverDomain)

        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        
        // Setup the session to make REST POST call
        var postParams : [String: AnyObject] = ["sessionInfo": sessionInfo,
                                                "sReportName": "AppFormPermissionListPending",
                                                "pPageIni": page * pageItem + 1,
                                                "pPageEnd": (page + 1) * pageItem + 1]
        switch self.orderType {
        case 0:
            postParams["orderColum"] = "changeDate"
            break
        case 1:
            postParams["orderColum"] = "startDate"
            break
        default:
            postParams["orderColum"] = "status"
            break
        }
        
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print(postParams)
        } catch {
            print("bad things happened")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.indicator .stopAnimating()
            })

            self.loading = false
            
            guard error == nil && data != nil else {
                // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            do {
                if let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    print(jsonData)
                    if let _  = jsonData["data"] {
                        if self.page == 0 {
                            self.permisosData = jsonData["data"] as? [NSDictionary]
                            self.loadMore = (self.permisosData?.count == self.pageItem)
                        }
                        else {
                            if let result = jsonData["data"] as? [NSDictionary] {
                                
                                self.loadMore = (result.count == self.pageItem)
                                
                                if result.count > 0 {
                                    for i in 0...result.count - 1 {
                                        let dict = result[i] as NSDictionary
                                        self.permisosData?.append(dict)
                                    }
                                }
                            }
                            else {
                                self.loadMore = false
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.tableView.reloadData()
                            if self.page == 0 {
                                self.tableView.setContentOffset(CGPointZero, animated:false)
                            }
                            self.page += 1
                        })
                    }
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }

    // MARK: UITableViewDelegate&DataSource methods

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = self.permisosData {
            return self.permisosData!.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:PermisosTableViewCell = tableView.dequeueReusableCellWithIdentifier("PermisosTableViewCellIdentifier", forIndexPath: indexPath) as! PermisosTableViewCell
        
        let data = self.permisosData![indexPath.row] as NSDictionary
        
        cell.setPermisos(data)
        
        if (indexPath.row == self.permisosData!.count - 5) {
            self .loadData()
        }
        
        return cell
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        var scrollDirection as Scroll
        
        if self.showOrderView == true {
            self.orderButtonClick(0)
        }
        if scrollView.contentOffset.y < 0 {
            return
        }
        
        if self.lastContentOffset > scrollView.contentOffset.y {
        
            // up
            if (self.addButton .alpha == 0 && self.animation == false) {
                
                self.animation = true
                
                UIView .animateWithDuration(0.25, animations: {
                    self.addButton .alpha = 1
                    }, completion: { (Bool) in
                        self.animation = false
                })
            }
        }
        else if self.lastContentOffset < scrollView.contentOffset.y {
            //down
            if (self.addButton .alpha == 1 && self.animation == false) {
                
                self.animation = true
                
                UIView .animateWithDuration(0.25, animations: {
                    self.addButton .alpha = 0
                    }, completion: { (Bool) in
                        self.animation = false
                })
            }
        }
        self.lastContentOffset = scrollView.contentOffset.y;

    }
}


extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.startIndex.advancedBy(1)
            let hexColor = hexString.substringFromIndex(start)
            
            if hexColor.characters.count == 6 {
                let scanner = NSScanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexLongLong(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }
        
        return nil
    }
}