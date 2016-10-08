//
//  DayView.swift
//  Pods
//
//  Created by Michał Jackowski on 21.09.2015.
//
//

import UIKit
import NSDate_Escort
//import STZPopupView

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}

public class MJDayView: MJComponentView {

 
    var date: NSDate! {
        didSet {
            self.updateView()
        }
    }
    var todayDate: NSDate!
    var userInfoForNotification: NSDictionary!
    var label: UILabel!
    var borderView: UIView!
//    var lblTimeFrom : UILabel!
//    var lblTimeto : UILabel!
    var finalArray1: NSMutableArray? = []
    var events: [NSDictionary]?
    var eventViews = [UILabel]()
    
    let dateFormatterTime = NSDateFormatter()
    let dateFormatter = NSDateFormatter()
    
    var isSameMonth = true {
        didSet {
            if isSameMonth != oldValue {
                self.updateView()
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(date: NSDate, delegate: MJComponentDelegate) {
        self.date = date
        self.todayDate = NSDate().dateAtStartOfDay()
        self.dateFormatterTime.dateFormat = "HH:mm"
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        super.init(delegate: delegate)
//        self.loadTestDataFromFile()
        self.setUpGesture()
        self.setUpBorderView()
        self.setUpLabel()
        self.updateView()
    }
    
    func loadTestDataFromFile (){
        
        let error : NSError
        
        if let path = NSBundle.mainBundle().pathForResource("sampledata", ofType: "txt")
        {
            if let jsonData = NSData.init(contentsOfFile: path)
            {
                do{
                    if let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    {
                        let success : Bool
                        if (jsonResult.objectForKey("ok")?.boolValue == true){
                            let itemsArray: NSArray?   = jsonResult.objectForKey("data") as? NSArray;
                            if let itemsArray = itemsArray
                            {
                                for (item) in itemsArray
                                {
                                    if item.objectForKey("detailedText")?.length != 0 {
                                        finalArray1?.addObject(item)
                                    }
                                }
                            }
                        }
                    }
                }
                catch{
                    
                }
            }
            
        }
    }
    
    func setUpGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(MJDayView.didTap))
        self.addGestureRecognizer(tap)
    }
    
    func didTap() {
        if let castedEvents = self.events {
            if castedEvents.count > 0 {
                let dict = NSMutableDictionary()
                dict["data"] = castedEvents
                dict["date"] = self.date
                let noti = NSNotification.init(name: "dayDidTapped", object: self, userInfo: dict as [NSObject : AnyObject])
                NSNotificationCenter.defaultCenter().postNotification(noti)
            }
        }
    }
    
    func setUpBorderView() {
        self.borderView = UIView()
        self.addSubview(self.borderView)
    }
    
    func setUpLabel() {
        self.label = UILabel()
        self.label.textAlignment = .Left
        self.label.clipsToBounds = true
        
//        self.lblTimeto      = UILabel()
//        self.lblTimeFrom    = UILabel()
//        
//        self.lblTimeFrom?.textAlignment = .Left
//        self.lblTimeto?.textAlignment   = .Left
//        
//        self.lblTimeto?.clipsToBounds   = true
//        self.lblTimeFrom?.clipsToBounds = true
//        
//        self.lblTimeto?.textColor   = UIColor.blackColor()
//        self.lblTimeFrom?.textColor = UIColor.whiteColor()
//        
//        self.lblTimeto?.font    = UIFont.systemFontOfSize(10)
//        self.lblTimeFrom?.font  = UIFont.systemFontOfSize(10)
//        
//        lblTimeto?.minimumScaleFactor   = 0.5
//        lblTimeFrom?.minimumScaleFactor = 0.5
        
        self.addSubview(self.label)
        
    }
    
    override func updateFrame() {
        let labelSize = self.labelSize()
        let labelFrame = CGRectMake(0, 0, width(), labelSize.height)
        self.label.frame = labelFrame
        
        let dayViewSize = self.delegate.configurationWithComponent(self).dayViewSize
        let borderFrame = CGRectMake((self.width() - dayViewSize.width) / 2,
                                     (self.height() - dayViewSize.height) / 2, dayViewSize.width, dayViewSize.height)
        self.borderView.frame = borderFrame
        
        
        let eventSize = self.delegate.configurationWithComponent(self).eventsViewSize
        
        let count = eventViews.count
        let eventH = (self.height() - dayViewSize.height) / 3.0
        
        for i in 0..<count {
            let v = eventViews[i]
            
            v.frame = CGRectMake(0.0, CGFloat(i) * eventH + dayViewSize.height, self.width(), eventH)
        }
        
//        let lblTimeFormFrame    = CGRectMake(0, labelFrame.size.height + 5, self.width(), 13)
//        let lblTimeToFrame      = CGRectMake(0, lblTimeFormFrame.size.height + lblTimeFormFrame.origin.y, self.width(), 13)
//        
//        self.lblTimeFrom?.frame = lblTimeFormFrame
//        self.lblTimeto?.frame   = lblTimeToFrame;
        
    }
    
    func labelSize() -> CGSize {
        let dayViewSize = self.delegate.configurationWithComponent(self).dayViewSize
        let borderSize = self.delegate.configurationWithComponent(self).selectedBorderWidth
        let labelSize = self.delegate.configurationWithComponent(self).selectedDayType == .Filled
            ? dayViewSize
            : CGSizeMake(dayViewSize.width - 2 * borderSize, dayViewSize.height - 2 * borderSize)
        return labelSize
    }
    
    func updateView() {
        self.clearViews()
        
        events = self.delegate.eventsForDay(self, date: date)
        
        self.setText()
        self.setShape()
        self.setBackgrounds()
        self.setTextColors()
        self.setViewBackgrounds()
        self.setBorder()
    }
    
    func clearViews() {
        for v in eventViews {
            v.removeFromSuperview()
        }
        eventViews.removeAll()
    }
    
    func setText() {
                
        self.label.font = self.delegate.configurationWithComponent(self).dayTextFont
        let text = "\(self.date.day)"
        self.label.text = text
        
        if self.delegate.isDateOutOfRange(self, date: self.date) {
            return
        }
        
        if let castedEvents = self.events {
            
            
            let count = castedEvents.count
            for i in 0..<count {
                let event = castedEvents[i]
                
                let lbl = UILabel()
                lbl.textColor = UIColor.blackColor()
                lbl.adjustsFontSizeToFitWidth = true
                lbl.textAlignment = .Left
                eventViews.append(lbl)

                if count > 3 && eventViews.count == 3 {
                    lbl.text = "+\(count - 2)"
                    lbl.backgroundColor = UIColor.grayColor()
                    
                    if (DeviceType.IS_IPHONE_4_OR_LESS) {
                        lbl.font  = UIFont.boldSystemFontOfSize(12)
                    }
                    else if (DeviceType.IS_IPHONE_5) {
                        lbl.font  = UIFont.boldSystemFontOfSize(13)
                    }
                    else {
                        lbl.font  = UIFont.boldSystemFontOfSize(14)
                    }
                } else {
                    let dateFrom = dateFormatter.dateFromString((event["from"] as! String?)!)

                    if event["detailedText"] as! String == "BILBAO" {
                        lbl.text = dateFormatterTime.stringFromDate(dateFrom!)
                    } else {
                        lbl.text = event["detailedText"] as! String
                    }
                    
                    if event["detailedText"] as! String == "VACACIONES" {
                        lbl.text = "VAC"
                    }
                    
                    if event["detailedText"] as! String == "Sin asignar" {
                        lbl.text = dateFormatterTime.stringFromDate(dateFrom!)
                    }
                    
                    if event["detailedText"]?.length > 0 {
                        lbl.backgroundColor = self.hexStringToUIColor(event["bgColor"] as! String)
                    }
                    
                    if (DeviceType.IS_IPHONE_4_OR_LESS) {
                        lbl.font  = UIFont.boldSystemFontOfSize(10)
                    }
                    else if (DeviceType.IS_IPHONE_5) {
                        lbl.font  = UIFont.boldSystemFontOfSize(11)
                    }
                    else {
                        lbl.font  = UIFont.boldSystemFontOfSize(12)
                    }
                }
            
                if !self.isSameMonth {
                    lbl.textColor = UIColor.blackColor()
                    lbl.backgroundColor = UIColor.clearColor()
                } else {
                    lbl.textColor = UIColor.whiteColor()
                }
                
                self.addSubview(lbl)
            }
            
        }
        
//        let dFormatterForComparison = NSDateFormatter()
//        dFormatterForComparison.dateFormat = "yyyy-MM-dd"
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"/*find out and place date format from http://userguide.icu-project.org/formatparse/datetime*/
//        
//        let dateFormatterTime = NSDateFormatter()
//        dateFormatterTime.dateFormat = "HH:mm"
//        
//        for item in finalArray1!
//        {
//            let firstDate = self.getDateFrom(self.date.year, month: self.date.month, day: self.date.day)// as! NSDate
//            let secondDate = dateFormatter.dateFromString((item.objectForKey("day") as! String?)!) as NSDate!
//            let firstDateStr = dFormatterForComparison.stringFromDate(firstDate)
//            let secondDateStr = dFormatterForComparison.stringFromDate(secondDate)
//            
//            if secondDateStr == firstDateStr{
//                
//                self.userInfoForNotification = item as! NSDictionary
//                let dateTo      = dateFormatter.dateFromString((item.objectForKey("to") as! String?)!)
//                let dateFrom    = dateFormatter.dateFromString((item.objectForKey("from") as! String?)!)
//                
//                if item.objectForKey("detailedText") as! String == "BILBAO" {
//                    self.lblTimeFrom?.text  = dateFormatterTime.stringFromDate(dateFrom!)
//                }
//                else{
//                    self.lblTimeFrom?.text    = item.objectForKey("detailedText") as! String
//                }
//
//                //                self.lblTimeto?.text    = item.objectForKey("detailedText") as! String
//                //                self.lblTimeto?.backgroundColor     = self.hexStringToUIColor(item.objectForKey("bgColor") as! String)
//                
//                if self.isSameMonth {
//                    if self.delegate.isDateOutOfRange(self, date: self.date) {
//                        self.lblTimeFrom?.backgroundColor   = UIColor.clearColor()
//                        self.lblTimeFrom?.textColor   = UIColor.blackColor()
//                    } else {
//                        self.lblTimeFrom?.backgroundColor   = self.hexStringToUIColor(item.objectForKey("bgColor") as! String)
//                    }
//                } else {
//                    self.lblTimeFrom?.backgroundColor   = UIColor.clearColor()
//                    self.lblTimeFrom?.textColor   = UIColor.blackColor()
//                }
//
//                //                self.addSubview(self.lblTimeto)
//                self.addSubview(self.lblTimeFrom)
//            }
//            else
//            {
//                //                lblTimeto.removeFromSuperview()
//                //                lblTimeFrom.removeFromSuperview()
//            }
//        }
        
        
        let isToday = self.todayDate.timeIntervalSince1970 == self.date.timeIntervalSince1970
        if isToday {
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            self.label.layer.cornerRadius = self.label.frame.size.height / 2
            self.label.attributedText = NSAttributedString(string: text)
            //self.label.attributedText = NSAttributedString(string: text, attributes: underlineAttribute)
            
        } else {
            self.label.attributedText = NSAttributedString(string: text)
        }
    }
    
    func setShape() {
    }
    
    func setViewBackgrounds() {
        if self.isSameMonth {
            if self.delegate.isDateOutOfRange(self, date: self.date) {
                self.backgroundColor = self.delegate.configurationWithComponent(self).outOfRangeDayBackgroundColor
            } else {
                //                self.backgroundColor = self.delegate.configurationWithComponent(self).dayBackgroundColor
                let isToday = self.todayDate.timeIntervalSince1970 == self.date.timeIntervalSince1970
                if isToday {
                    self.backgroundColor = self.hexStringToUIColor("#c8e6c9")
                }else{
                    self.backgroundColor = UIColor.whiteColor()
                }
            }
        } else {
            self.backgroundColor = self.delegate.configurationWithComponent(self).otherMonthBackgroundColor
        }
    }
    
    func setTextColors() {
        
    }
    
    func setBackgrounds() {
    }
    
    func setBorder() {
        self.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.layer.borderWidth = 0.3
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func getDateFrom(year:Int, month:Int, day:Int) -> NSDate {
        let c = NSDateComponents()
        c.year = year
        c.month = month
        c.day = day
        
        let gregorian = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let date = gregorian!.dateFromComponents(c)
        return date!
    }
}
