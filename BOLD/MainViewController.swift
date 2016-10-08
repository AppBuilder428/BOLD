//
//  MainViewController.swift
//  BOLD
//
//  Created by admin on 6/3/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import STZPopupView
import NSDate_Escort
import MJCalendar
import HexColors

struct DayColors {
    var backgroundColor: UIColor
    var textColor: UIColor
}

class MainViewController: UIViewController, UIScrollViewDelegate, MJCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var calendarView: MJCalendarView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var calendarViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var dayColors = Dictionary<NSDate, DayColors>()
    var dateFormatter: NSDateFormatter!
    let eventsFormatter = NSDateFormatter()
    var currentCalendarDate = NSDate().dateAtStartOfDay()
    var refreshflg = 0
    var selectedDate: NSDate?
    let kRotationAnimationKey = "com.myapplication.rotationanimationkey" // Any key
    
    var popupTable: UITableView!
    var popupData: [NSDictionary]?
    
    var colors: [UIColor] {
        return [
            //            UIColor(hexString: "#f6980b"),
            //            UIColor(hexString: "#2081D9"),
            //            UIColor(hexString: "#2fbd8f"),
        ]
    }
    
    var monthData: [NSDictionary]?
    
    let daysRange = 365
    var isScrollingAnimation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleWithDate(NSDate())
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(showPopUp),
            name: "dayDidTapped",
            object: nil)
        
        self.statusView.backgroundColor = bgNavigationColor
        self.navigationView.backgroundColor = bgNavigationColor
        
        self.setUpDays()
        
        self.setUpCalendarConfiguration()
        
        self.dateFormatter = NSDateFormatter()
        self.setTitleWithDate(NSDate())
        
        self.eventsFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        self.loadData(currentCalendarDate)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissPopupView()
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    func setTitleWithDate(date: NSDate) {
        self.dateFormatter.dateFormat = "MMMM yyyy"
        self.lblMonth.text = self.dateFormatter.stringFromDate(date)
    }
    
    // call api to get detailed events datas from server.
    func loadData(date: NSDate) {
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/calendar", serverDomain)
        
        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        
        let first = calendarView.firstDate()
        let last = calendarView.lastDate()
        var key = 0
        var ind = -1
        let dtFrom = self.eventsFormatter.stringFromDate(first)
        let dtTo = self.eventsFormatter.stringFromDate(last)
        //        for object in monthlycache {
        //            if (object.valueForKey(dtFrom) != nil) {
        //                self.monthData = object.valueForKey(dtFrom) as? [NSDictionary]
        //                key = 1
        //                break
        //            }
        //        }
        
        for index in 0..<monthlycache.count{
            //add an element and the previous element together
            if (monthlycache[index].valueForKey(dtFrom) != nil ) {
                self.monthData = monthlycache[index].valueForKey(dtFrom) as? [NSDictionary]
                key = 1
                ind = index
                break
            }
        }
        
        if ( key == 1 && refreshflg == 0 ) {
            self.calendarView.reloadView()
        }
        //        else {
        //          let dtFrom = self.eventsFormatter.stringFromDate(date.dateAtStartOfMonth().dateBySubtractingDays(14))
        //          let dtTo = self.eventsFormatter.stringFromDate(date.dateAtEndOfMonth().dateByAddingDays(14))
        // Setup the session to make REST POST call
        //          let postParams : [String: AnyObject] = ["dtFrom": "2016-06-01T00:00:00", "dtTo":"2016-07-01T00:00:00", "sessionInfo":sessionInfo]
        let postParams : [String: AnyObject] = ["dtFrom": dtFrom, "dtTo": dtTo, "sessionInfo":sessionInfo]
        
        // Create the request
        //            let request = NSMutableURLRequest(URL: url)
        
        // Animation rotation the button
        self.rotateView(self.refreshButton)
        
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
                self.stopRotatingView(self.refreshButton)
            })
            
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
                        self.monthData = jsonData["data"] as? [NSDictionary]
                        let cachedata : [String: AnyObject] = [dtFrom : (jsonData["data"] as? [NSDictionary])!]
                        if ( key == 1 ){
                            monthlycache.removeObjectAtIndex(ind)
                        }
                        monthlycache.addObject(cachedata)
                        print(monthlycache)
                        dispatch_async(dispatch_get_main_queue(), {
                            if ( key == 0 || self.refreshflg == 1) {
                                self.calendarView.reloadView()
                                self.refreshflg = 0
                            }
                        })
                    }
                    
                }
            } catch {
                print(error)
            }
            
        }
        task.resume()
        //        }
    }
    
    // MARK: helper method.
    func rotateView(view: UIView, duration: Double = 1) {
        if view.layer.animationForKey(kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float(M_PI * 2.0)
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            view.layer.addAnimation(rotationAnimation, forKey: kRotationAnimationKey)
        }
    }
    
    func stopRotatingView(view: UIView) {
        if view.layer.animationForKey(kRotationAnimationKey) != nil {
            view.layer.removeAnimationForKey(kRotationAnimationKey)
        }
    }
    
    // MARK: IBAction method.
    @IBAction func RefreshBtn(sender: AnyObject) {
        refreshflg = 1
        loadData(currentCalendarDate)
        
        
    }
    
    
    @IBAction func MenuBtn(sender: AnyObject) {
        toggleSideMenuView()
    }
    func setUpCalendarConfiguration() {
        //        let date = NSDate()
        //        self.calendarView.selectDate(date)
        
        self.calendarView.calendarDelegate = self
        
        // Set displayed period type. Available types: Month, ThreeWeeks, TwoWeeks, OneWeek
        self.calendarView.configuration.periodType = .Month
        
        // Set shape of day view. Available types: Circle, Square
        self.calendarView.configuration.dayViewType = .Circle
        
        // Set selected day display type. Available types:
        // Border - Only border is colored with selected day color
        // Filled - Entire day view is filled with selected day color
        self.calendarView.configuration.selectedDayType = .Border
        
        // Set width of selected day border. Relevant only if selectedDayType = .Border
        self.calendarView.configuration.selectedBorderWidth = 1
        
        // Set day text color
        self.calendarView.configuration.dayTextColor = UIColor(hexString: "6f787c")
        
        // Set day background color
        self.calendarView.configuration.dayBackgroundColor = UIColor(hexString: "f0f0f0")
        
        // Set selected day text color
        self.calendarView.configuration.selectedDayTextColor = UIColor.whiteColor()
        
        // Set selected day background color
        //        self.calendarView.configuration.selectedDayBackgroundColor = UIColor(hexString: "6f787c")
        
        // Set other month day text color. Relevant only if periodType = .Month
        self.calendarView.configuration.otherMonthTextColor = UIColor(hexString: "6f787c")
        
        // Set other month background color. Relevant only if periodType = .Month
        self.calendarView.configuration.otherMonthBackgroundColor = UIColor(hexString: "E7E7E7")
        
        // Set week text color
        self.calendarView.configuration.weekLabelTextColor = UIColor(hexString: "6f787c")
        
        // Set start day. Available type: .Monday, Sunday
        self.calendarView.configuration.startDayType = .Monday
        
        
        // Set day text font
        self.calendarView.configuration.dayTextFont = UIFont.systemFontOfSize(13)
        
        //Set week's day name font
        self.calendarView.configuration.weekLabelFont = UIFont.systemFontOfSize(13)
        
        //Set day view size. It includes border width if selectedDayType = .Border
        self.calendarView.configuration.dayViewSize = CGSizeMake(24, 24)
        
        //Set height of row with week's days
        
        self.calendarView.configuration.rowHeight = (CGRectGetHeight(UIScreen .mainScreen().bounds) - 87 - 25) / 6 //50
        
        // Set height of week's days names view
        self.calendarView.configuration.weekLabelHeight = 25
        
        // To commit all configuration changes execute reloadView method
        self.calendarView.reloadView()
    }
    
    func titleWithDate(date: NSDate) {
        let dateFormatter1 = NSDateFormatter()
        dateFormatter1.dateFormat = "MMMM yyyy"
        self.lblMonth.text = dateFormatter1.stringFromDate(date)
    }
    
    func setUpDays() {
        for i in 0...self.daysRange {
            let day = self.dateByIndex(i)
            let dayColors = DayColors(backgroundColor: UIColor.clearColor(), textColor: UIColor.blackColor())
            self.dayColors[day] = dayColors
        }
    }
    
    func randColor() -> UIColor? {
        if arc4random() % 2 == 0 {
            let colorIndex = Int(arc4random()) % self.colors.count
            let color = self.colors[colorIndex]
            return color
        }
        
        return nil
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.isScrollingAnimation = false
    }
    
    func dateByIndex(index: Int) -> NSDate {
        let startDay = NSDate().dateAtStartOfDay().dateBySubtractingDays(self.daysRange / 2)
        let day = startDay.dateByAddingDays(index)
        return day
    }
    
    func scrollTableViewToDate(date: NSDate) {
        //        if let row = self.indexByDate(date) {
        //            let indexPath = NSIndexPath(forRow: row, inSection: 0)
        //            self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
        //            self.isScrollingAnimation = true
        //            self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        //        }
    }
    
    func indexByDate(date: NSDate) -> Int? {
        let startDay = NSDate().dateAtStartOfDay().dateBySubtractingDays(self.daysRange / 2)
        let index = date.daysAfterDate(startDay)
        if index >= 0 && index <= self.daysRange {
            return index
        } else {
            return nil
        }
    }
    
    //MARK: MJCalendarViewDelegate
    func calendar(calendarView: MJCalendarView, didChangePeriod periodDate: NSDate, bySwipe: Bool) {
        // Sets month name according to presented dates
        self.setTitleWithDate(periodDate)
        
        // bySwipe diffrentiate changes made from swipes or select date method
        if bySwipe {
            // Scroll to relevant date in tableview
            self.scrollTableViewToDate(periodDate)
            self.monthData = nil
            
            self.currentCalendarDate = periodDate
            self.loadData(periodDate)
        }
    }
    
    func calendar(calendarView: MJCalendarView, backgroundForDate date: NSDate) -> UIColor? {
        return self.dayColors[date]?.backgroundColor
    }
    
    func calendar(calendarView: MJCalendarView, textColorForDate date: NSDate) -> UIColor? {
        return self.dayColors[date]?.textColor
    }
    
    func calendar(calendarView: MJCalendarView, didSelectDate date: NSDate) {
        self.scrollTableViewToDate(date)
    }
    
    func calendar(calendarView: MJCalendarView, eventsForDate: NSDate) -> [NSDictionary]? {
        
        guard let castedData = self.monthData else {
            return nil
        }
        
        var events = [NSDictionary]()
        
        for data in castedData {
            let dateString = data["day"] as! String
            let date = self.eventsFormatter.dateFromString(dateString)!
            
            if date.day == eventsForDate.day && date.month == eventsForDate.month && date.year == eventsForDate.year {
                events.append(data)
            }
            
        }
        
        // sorting
        //        if events.count > 0 {
        //        print("Events \(eventsForDate)")
        //        }
        return events
    }
    
    //MARK: Toolbar actions
    @IBAction func didTapMonth(sender: AnyObject) {
        self.animateToPeriod(.Month)
    }
    
    @IBAction func didTapThreeWeeks(sender: AnyObject) {
        self.animateToPeriod(.ThreeWeeks)
    }
    
    @IBAction func didTapTwoWeeks(sender: AnyObject) {
        self.animateToPeriod(.TwoWeeks)
    }
    
    @IBAction func didTapOneWeek(sender: AnyObject) {
        self.animateToPeriod(.OneWeek)
    }
    
    func animateToPeriod(period: MJConfiguration.PeriodType) {
        self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
        
        self.calendarView.animateToPeriodType(period, duration: 0.2, animations: { (calendarHeight) -> Void in
            // In animation block you can add your own animation. To adapat UI to new calendar height you can use calendarHeight param
            self.calendarViewHeight.constant = calendarHeight
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func showPopUp (notification: NSNotification)
    {
        
        let t : NSDictionary = notification.userInfo as! [NSObject: NSDictionary]
        let arr = t["data"] as! NSArray
        popupData = arr as? [NSDictionary]
        //        let tmp = arr[0]
        let cnt = popupData?.count
        var ht = CGFloat(135 + 50)
        
        if cnt > 1 {
            ht = CGFloat(210 + 50)
        }
        
        if cnt > 2 {
            ht = CGFloat(250 + 50)
        }
        
        //        let strTo : String = tmp.objectForKey("to") as! String
        //        let strFrom : String = tmp.objectForKey("from") as! String
        
        let selectedDate = t.objectForKey("date") as! NSDate
        self.selectedDate = selectedDate
        
        let popupView = UIView()
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width-60, ht)
        print(popupView.frame)
        popupView.backgroundColor = UIColor.whiteColor()
        
        let dateLabel = UILabel()
        dateLabel.textColor = UIColor.lightGrayColor()
        dateLabel.frame = CGRectMake(0, 0, popupView.frame.size.width, 60)
        
        dateFormatter.dateFormat = "dd MMM"
        dateLabel.text = "\(dateFormatter.stringFromDate(selectedDate))";
        dateLabel.font = UIFont.systemFontOfSize(30)
        dateLabel.textAlignment = NSTextAlignment.Center
        popupView.addSubview(dateLabel)
        
        let separatorLabel = UILabel()
        separatorLabel.backgroundColor = UIColor.lightGrayColor()
        separatorLabel.frame = CGRectMake(20, 60, popupView.frame.size.width-40, 1)
        popupView.addSubview(separatorLabel)
        
        
        //
        popupTable = UITableView(frame: CGRectMake(0.0, 62.0, self.view.bounds.size.width-60, ht-62.0 - 50), style: .Plain)
        popupTable.delegate = self
        popupTable.dataSource = self
        popupTable.allowsSelection = false
        popupTable.separatorColor = UIColor.clearColor()
        popupTable.alwaysBounceVertical = false
        popupTable.alwaysBounceHorizontal = false
        popupTable.bounces = false
        popupView.addSubview(popupTable)
        
        let buttonFrame = CGRectMake(10.0, ht - 52.0 + 5, self.view.bounds.size.width-80, 40)
        let addNewButton = UIButton.init(type: UIButtonType.Custom)
        addNewButton.frame = buttonFrame
        addNewButton.backgroundColor = UIColor.init(56, green: 142, blue: 61)
        addNewButton .setTitle("SOLICITAR NUEVO PERMISO", forState: UIControlState.Normal)
        addNewButton.titleLabel?.textColor = UIColor.whiteColor()
        addNewButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        addNewButton.layer.cornerRadius = 2
        addNewButton.addTarget(self, action: #selector(MainViewController.addNewItem), forControlEvents: .TouchUpInside)
        popupView.addSubview(addNewButton)
        
        let config = STZPopupViewConfig.init()
        config.showAnimation = STZPopupShowAnimation.SlideInFromTop
        config.dismissAnimation = STZPopupDismissAnimation.SlideOutToBottom
        
        if ( popupData?.count > 0 && popupData![0]["detailedText"] as! String != ""){
            print(popupData?.count)
            presentPopupView(popupView, config: config)
        }
    }
    
    func addNewItem() {
        
        dismissPopupView()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("soliciatar") as!AddPermisosViewController
        destViewController.selectedDate = self.selectedDate
        
        self.navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popupData!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            
            let colorLabel = UILabel()
            colorLabel.frame = CGRectMake(0, 0, 10, 70)
            colorLabel.tag = 1
            cell?.contentView.addSubview(colorLabel)
            
            let timeLabel = UILabel()
            timeLabel.textColor = UIColor.lightGrayColor()
            timeLabel.frame = CGRectMake(40, 5, tableView.frame.size.width-40, 20)
            timeLabel.font = UIFont.systemFontOfSize(15)
            timeLabel.textAlignment = NSTextAlignment.Left
            timeLabel.tag = 2
            cell?.contentView.addSubview(timeLabel)
            
            let eventDetailLabel = UILabel()
            eventDetailLabel.textColor = UIColor.lightGrayColor()
            eventDetailLabel.frame = CGRectMake(40, 30, tableView.frame.size.width-40, 30)
            eventDetailLabel.textAlignment = NSTextAlignment.Left
            if #available(iOS 8.2, *) {
                eventDetailLabel.font = UIFont.systemFontOfSize(23, weight: 0.2)
            } else {
                // Fallback on earlier versions
            }
            eventDetailLabel.tag = 4
            cell?.contentView.addSubview(eventDetailLabel)
            
        }
        
        if let castedData = popupData {
            let data = castedData[indexPath.row]
            let colorLabel = cell?.contentView.viewWithTag(1) as! UILabel
            colorLabel.backgroundColor = UIColor(hexString: data["bgColor"] as? String)
            
            let timeLabel = cell?.contentView.viewWithTag(2) as! UILabel
            let strTo  = self.eventsFormatter.dateFromString( data["to"] as! String)
            let strFrom  = self.eventsFormatter.dateFromString( data["from"] as! String)
            
            dateFormatter.dateFormat = "HH:mm"
            timeLabel.text = "\(dateFormatter.stringFromDate(strFrom!))-\(dateFormatter.stringFromDate(strTo!))"
            
            let eventDetailLabel = cell?.contentView.viewWithTag(4) as! UILabel
            eventDetailLabel.text = data["detailedText"] as? String
        }
        
        return cell!
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
}

