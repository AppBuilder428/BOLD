//
//  AddPermisosViewController.swift
//  BOLD
//
//  Created by admin on 6/14/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import STZPopupView

class AddPermisosViewController: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var tipoButton: UIButton!
    
    @IBOutlet weak var inforButton: UIButton!
    @IBOutlet weak var inforButtonLCWidth: NSLayoutConstraint!

    @IBOutlet weak var startDateTitleLabel: UILabel!
    @IBOutlet weak var endDateTitleLabel: UILabel!
    
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!

//    @IBOutlet weak var daySegmentControl: UISegmentedControl!
    @IBOutlet weak var allDayButton: UIButton!

    @IBOutlet weak var timeContainerView: UIView!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    var picker: UIDatePicker?
    var outputDateFormatter: NSDateFormatter?
    var outputTimeFormatter: NSDateFormatter?

    var groupsData = [String: AnyObject]()
    var selectedDate: NSDate?
    var startDate: NSDate?
    var endDate: NSDate?
    var startTime: NSDate?
    var endTime: NSDate?
    var allDay: Bool = true
    var currentYear: Int = 0
    var allowSelectTime = false
    
    var selectedGroupPosition: Int?
    var selectedTipoPosition: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationView.backgroundColor = bgNavigationColor

        self.loadGroupData()
        
        self.groupButton.enabled = false
        self.tipoButton.enabled = false
        self.hideSelectDate(true)
        self.updateInfoButtonWithLegal("")
        
        let cal = NSCalendar.currentCalendar()
        self.currentYear = cal.component([NSCalendarUnit.Year], fromDate: NSDate())
        
        self.outputTimeFormatter = NSDateFormatter()
        self.outputTimeFormatter?.dateFormat = "HH:mm"
        
        self.selectedGroupPosition = -1
        self.selectedTipoPosition = -1
        
        if let _ = self.selectedDate {
            
            let coms = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self.selectedDate!) as NSDateComponents
            self.startDate = cal .dateFromComponents(coms)
            self.endDate = self.startDate
            self.startTime = self.startDate
            self.endTime = self.startDate
        
//            self.startDate = self.selectedDate
//            self.endDate = self.selectedDate
//            self.startTime = self.selectedDate
//            self.endTime = self.selectedDate
        }
        else {
            
            let coms = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: NSDate()) as NSDateComponents
            self.startDate = cal .dateFromComponents(coms)
            self.endDate = self.startDate
            self.startTime = self.startDate
            self.endTime = self.startDate
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func BackBtn(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func groupButtonClick(sender: AnyObject) {
        
        let count = self.groupsData.count / 2 as Int
        
        let popupView = UIView()
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width-60, (CGFloat(count) + 1) * 40.0)
        popupView.backgroundColor = UIColor.whiteColor()
        popupView.layer.borderColor = UIColor.init(105, green: 105, blue: 105).CGColor
        popupView.layer.borderWidth = 2
        popupView.clipsToBounds = true

        let dateLabel = UILabel()
        dateLabel.textColor = UIColor.init(32, green: 32, blue: 32)
        dateLabel.frame = CGRectMake(10, 0, popupView.frame.size.width - 20, 40)
        dateLabel.font = UIFont.boldSystemFontOfSize(17)
        dateLabel.textAlignment = NSTextAlignment.Left
        dateLabel.text = "Grupo"
        popupView.addSubview(dateLabel)
        
        let lineView = UIView()
        lineView.frame = CGRectMake(0, 40, popupView.frame.size.width, 2)
        lineView.backgroundColor = bgNavigationColor
        popupView.addSubview(lineView)

        for i in 0...count - 1 {
            var key = self.groupsData[String.init(format: "%d",i)] as! String

            key = String(key.characters.first!).capitalizedString + String(key.characters.dropFirst()).lowercaseString

            let buttonFrame = CGRectMake(10.0, 40 * (CGFloat(i) + 1), popupView.frame.size.width - 20, 40)
            let itemButton = UIButton.init(type: UIButtonType.Custom)
            itemButton.frame = buttonFrame
            itemButton .setTitle(key, forState: UIControlState.Normal)
            itemButton.setTitleColor(UIColor.init(32, green: 32, blue: 32), forState: UIControlState.Normal)
            itemButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
            itemButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
            itemButton.layer.cornerRadius = 2
            itemButton.tag = i
            itemButton.addTarget(self, action: #selector(AddPermisosViewController.selectGrupoItem), forControlEvents: .TouchUpInside)
            popupView.addSubview(itemButton)
            
            let lineView = UIView()
            lineView.frame = CGRectMake(0, 40 * (CGFloat(i) + 2), popupView.frame.size.width, 1)
            lineView.backgroundColor = UIColor.init(192, green: 192, blue: 192)
            popupView.addSubview(lineView)

        }
        
        self.showPopupView(popupView)
    }
    
    func selectGrupoItem(sender: AnyObject) {

        dismissPopupView()
        
        let button = sender as! UIButton
        self.selectedGroupPosition = button.tag
        self.fillGroupData(button.tag)
    }
    
    @IBAction func tipoButtonClick(sender: AnyObject) {
        
        let key = self.groupsData[String.init(format: "%d", self.selectedGroupPosition!)] as! String
        let groups = self.groupsData[key] as! NSMutableArray

        let popupView = UIView()
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width-60, (CGFloat(groups.count) + 1) * 40.0)
        popupView.backgroundColor = UIColor.whiteColor()
        popupView.layer.borderColor = UIColor.init(105, green: 105, blue: 105).CGColor
        popupView.layer.borderWidth = 2
        popupView.clipsToBounds = true
        
        let dateLabel = UILabel()
        dateLabel.textColor = UIColor.init(32, green: 32, blue: 32)
        dateLabel.frame = CGRectMake(10, 0, popupView.frame.size.width - 20, 40)
        dateLabel.font = UIFont.boldSystemFontOfSize(17)
        dateLabel.textAlignment = NSTextAlignment.Left
        dateLabel.text = "Tipo"
        popupView.addSubview(dateLabel)
        
        let lineView = UIView()
        lineView.frame = CGRectMake(0, 40, popupView.frame.size.width, 2)
        lineView.backgroundColor = bgNavigationColor
        popupView.addSubview(lineView)

        for i in 0...groups.count - 1 {
            let group = groups[i] as! NSDictionary
            
            let buttonFrame = CGRectMake(10.0, 40 * (CGFloat(i) + 1), popupView.frame.size.width - 20, 40)
            let itemButton = UIButton.init(type: UIButtonType.Custom)
            itemButton.frame = buttonFrame
            
            if let _ = group.objectForKey("descr") {
                var descr = group.objectForKey("descr") as! String
                descr = String(descr.characters.first!).capitalizedString + String(descr.characters.dropFirst()).lowercaseString

                itemButton .setTitle(descr, forState: UIControlState.Normal)
            }

            itemButton.setTitleColor(UIColor.init(32, green: 32, blue: 32), forState: UIControlState.Normal)
            itemButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
            itemButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
            itemButton.layer.cornerRadius = 2
            itemButton.tag = i
            itemButton.addTarget(self, action: #selector(AddPermisosViewController.selectTypoItem), forControlEvents: .TouchUpInside)
            popupView.addSubview(itemButton)
            
            let lineView = UIView()
            lineView.frame = CGRectMake(0, 40 * (CGFloat(i) + 2), popupView.frame.size.width, 1)
            lineView.backgroundColor = UIColor.init(192, green: 192, blue: 192)
            popupView.addSubview(lineView)
        }
        
        self.showPopupView(popupView)
    }
    
    func selectTypoItem(sender: AnyObject) {
        
        dismissPopupView()
        let button = sender as! UIButton
        self.selectedTipoPosition = button.tag

        let key = self.groupsData[String.init(format: "%d", self.selectedGroupPosition!)] as! String
        let groups = self.groupsData[key] as! NSMutableArray
        let group = groups[sender.tag] as! NSDictionary

        if let _ = group.objectForKey("descr") {
            
            var descr = group.objectForKey("descr") as! String
            descr = String(descr.characters.first!).capitalizedString + String(descr.characters.dropFirst()).lowercaseString

            self.tipoButton .setTitle(descr, forState: UIControlState.Normal)
            
            let legal = group.objectForKey("legal") as! String
            self.updateInfoButtonWithLegal(legal)
            
            if let _ = group.objectForKey("assignType") {
                let assignType = group.objectForKey("assignType") as! Int
                
                self.timeContainerView.hidden = (assignType == 1)

                if assignType == 0 {
                    self.allDayButton .setImage(UIImage.init(named: "button_on"), forState: UIControlState.Normal)
                    self.timeTitle.text = "Día completo"
                    self.startTimeButton.hidden = true
                    self.endTimeButton.hidden = true
                    self.allDay = true
                    
                    self.setOutputFormatter(self.currentYear, day: startDate!.description)
                    self.startDateButton .setTitle(self.outputDateFormatter?.stringFromDate(self.startDate!), forState: UIControlState.Normal)
                    
                    self.setOutputFormatter(self.currentYear, day: endDate!.description)
                    self.endDateButton .setTitle(self.outputDateFormatter?.stringFromDate(self.endDate!), forState: UIControlState.Normal)
                }
                else {
                    self.allDay = false
                }
            }
        }
        self.hideSelectDate(false)
    }
    
    @IBAction func inforButtonClick(sender: AnyObject) {
        
        let key = self.groupsData[String.init(format: "%d", self.selectedGroupPosition!)] as! String
        let groups = self.groupsData[key] as! NSMutableArray
        let group = groups[self.selectedTipoPosition!] as! NSDictionary
        let legal = group.objectForKey("legal") as! String
        let descr = group.objectForKey("descr") as! String

        let popupView = UIView()
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width-60, 80.0)
        popupView.backgroundColor = UIColor.whiteColor()
        
        let dateLabel = UILabel()
        dateLabel.textColor = UIColor.init(32, green: 32, blue: 32)
        dateLabel.frame = CGRectMake(10, 0, popupView.frame.size.width - 20, 40)
        dateLabel.font = UIFont.boldSystemFontOfSize(15)
        dateLabel.textAlignment = NSTextAlignment.Left
        dateLabel.text = descr
        popupView.addSubview(dateLabel)

        let legalLabel = UILabel()
        legalLabel.textColor = UIColor.init(32, green: 32, blue: 32)
        legalLabel.frame = CGRectMake(10, 40, popupView.frame.size.width - 20, 40)
        legalLabel.font = UIFont.boldSystemFontOfSize(15)
        legalLabel.textAlignment = NSTextAlignment.Left
        legalLabel.text = legal
        popupView.addSubview(legalLabel)
        
        self.showPopupView(popupView)
    }

    func datePickerSelected(sender: AnyObject) {
        let button = sender as! UIButton
        
        dismissPopupView()
        
        switch button.tag {
        case 1: // start day
            self.setOutputFormatter(self.currentYear, day: self.picker!.date.description)
            self.startDateButton .setTitle(self.outputDateFormatter?.stringFromDate(self.picker!.date), forState: UIControlState.Normal)
            self.startDate = self.picker!.date
            self.startTime = self.picker!.date
            
            if let _ = self.endDate {
                if self.startDate!.compare(self.endDate!) == NSComparisonResult.OrderedDescending {
                    self.endDate = self.startDate
                    self.endDateButton.setTitle(self.outputDateFormatter?.stringFromDate(self.picker!.date), forState: UIControlState.Normal)
                }
            }

            break;
            
        case 3: // end day
            
            if let _ = self.startDate {
                if self.startDate!.compare(self.endDate!) == NSComparisonResult.OrderedDescending {
                    // TODO: show the message.
//                    self.showErrorMessage("Please select other day")
                    return
                }
            }

            self.setOutputFormatter(self.currentYear, day: self.picker!.date.description)
            self.endDateButton.setTitle(self.outputDateFormatter?.stringFromDate(self.picker!.date), forState: UIControlState.Normal)
            self.endDate = self.picker!.date
            self.endTime = self.picker!.date

            if self.allowSelectTime == true {
                if self.endDate!.compare(self.startDate!) == NSComparisonResult.OrderedSame {
                    self.timeContainerView.hidden = false
                }
                else {
                    self.timeContainerView.hidden = true
                }
            }
            break;
            
        case 5: // start time
            self.startTimeButton .setTitle(self.outputTimeFormatter?.stringFromDate(self.picker!.date), forState: UIControlState.Normal)
            self.startTime = self.picker!.date
            break;
            
        case 7: // end time
            self.endTimeButton .setTitle(self.outputTimeFormatter?.stringFromDate(self.picker!.date), forState: UIControlState.Normal)
            self.endTime = self.picker!.date
            break;
        default:
            break;
        }
    }
    
    func showErrorMessage(message: String) {
        
        let message = String.init(format: "ERROR \n%@", message)
        let height = message.stringHeightWidth(14, width: self.view.bounds.size.width - 40)
        
        let popupView = UIView()
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 20, height + 20)
        popupView.backgroundColor = UIColor.whiteColor()
        
        let errorLabel = UILabel()
        errorLabel.textColor = UIColor.blackColor()
        errorLabel.frame = CGRectMake(10, 10, self.view.bounds.size.width - 40, height)
        errorLabel.numberOfLines = 20
        errorLabel.font = UIFont.systemFontOfSize(14)
        errorLabel.textAlignment = NSTextAlignment.Left
        errorLabel.text = message
        popupView.addSubview(errorLabel)
        
        showPopupView(popupView)
    }
    
    func initPicker() {
        if let _ = self.picker {
        }
        else {
            self.picker =  UIDatePicker()
        }
    }
    
    @IBAction func startDateButtonClick(sender: AnyObject) {
        
        self.initPicker()
        self.picker!.datePickerMode = UIDatePickerMode.Date
        if let _ = self.startDate {
            self.picker!.setDate(self.startDate!, animated: false)
        }
        
        let popupView = UIView()
        
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 256)
        popupView.backgroundColor = UIColor.whiteColor()
        popupView.addSubview(self.picker!)
        
        // Add 2 button OK and Cancel
        var buttonFrame = CGRectMake(0.0, 216, popupView.frame.size.width/2, 40)
        let cancelButton = self.cancelButton(buttonFrame, tag: 0)
        popupView.addSubview(cancelButton)

        buttonFrame = CGRectMake(popupView.frame.size.width/2, 216, popupView.frame.size.width/2, 40)
        let setButton = self.setButton(buttonFrame, tag: 1)
        popupView.addSubview(setButton)
        
        self.showPopupView(popupView)
    }
    
    @IBAction func endDateButtonClick(sender: AnyObject) {
        self.initPicker()
        self.picker!.datePickerMode = UIDatePickerMode.Date
        if let _ = self.endDate {
            self.picker!.setDate(self.endDate!, animated: false)
        }
        
        let popupView = UIView()
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 256)
        popupView.backgroundColor = UIColor.whiteColor()
        popupView.addSubview(self.picker!)
        
        // Add 2 button OK and Cancel
        var buttonFrame = CGRectMake(0.0, 216, popupView.frame.size.width/2, 40)
        let cancelButton = self.cancelButton(buttonFrame, tag: 2)
        popupView.addSubview(cancelButton)
        
        buttonFrame = CGRectMake(popupView.frame.size.width/2, 216, popupView.frame.size.width/2, 40)
        let setButton = self.setButton(buttonFrame, tag: 3)
        popupView.addSubview(setButton)
        
        self.showPopupView(popupView)
    }
    
    @IBAction func completedDayClick(sender: AnyObject) {
        
        // Change the value
        if (self.allDayButton.tag ==  0) {
            self.allDayButton.tag = 1
        }
        else {
            self.allDayButton.tag = 0
        }
        
        if (self.allDayButton.tag == 0) {
            
            self.allDayButton .setImage(UIImage.init(named: "button_on"), forState: UIControlState.Normal)

            self.timeTitle.text = "Día completo"
            self.startTimeButton.hidden = true
            self.endTimeButton.hidden = true
            self.endDateButton.enabled = true
            
            self.setOutputFormatter(self.currentYear, day: endDate!.description)
            self.endDateButton .setTitle(self.outputDateFormatter?.stringFromDate(self.endDate!), forState: UIControlState.Normal)
            
            self.allDay = true

        }
        else {
            
            self.allDayButton .setImage(UIImage.init(named: "button_off"), forState: UIControlState.Normal)

            self.timeTitle.text = "Horas a solicitar"
            
            self.endDateButton .setTitle("--------", forState: UIControlState.Normal)
            self.endDateButton.enabled = false
            self.startTimeButton.hidden = false
            self.endTimeButton.hidden = false
            self.endDate = self.startDate
            self.endTime = self.endDate
            self.allDay = false

        }
    }

    @IBAction func startTimeButtonClick(sender: AnyObject) {
        
        self.initPicker()
        self.picker!.datePickerMode = UIDatePickerMode.Time
        if let _ = self.startTime {
            self.picker!.setDate(self.startTime!, animated: false)
        }
        
        let popupView = UIView()
        
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 256)
        popupView.backgroundColor = UIColor.whiteColor()
        popupView.addSubview(self.picker!)
        
        // Add 2 button OK and Cancel
        var buttonFrame = CGRectMake(0.0, 216, popupView.frame.size.width/2, 40)
        let cancelButton = self.cancelButton(buttonFrame, tag: 0)
        popupView.addSubview(cancelButton)
        
        buttonFrame = CGRectMake(popupView.frame.size.width/2, 216, popupView.frame.size.width/2, 40)
        let setButton = self.setButton(buttonFrame, tag: 5)
        popupView.addSubview(setButton)
        
        self.showPopupView(popupView)
    }
    
    @IBAction func endTimeButtonClick(sender: AnyObject) {
        
        self.initPicker()
        self.picker!.datePickerMode = UIDatePickerMode.Time
        if let _ = self.endTime {
            self.picker!.setDate(self.endTime!, animated: false)
        }
        
        let popupView = UIView()
        
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 256)
        popupView.backgroundColor = UIColor.whiteColor()
        popupView.addSubview(self.picker!)
        
        // Add 2 button OK and Cancel
        var buttonFrame = CGRectMake(0.0, 216, popupView.frame.size.width/2, 40)
        let cancelButton = self.cancelButton(buttonFrame, tag: 0)
        popupView.addSubview(cancelButton)
        
        buttonFrame = CGRectMake(popupView.frame.size.width/2, 216, popupView.frame.size.width/2, 40)
        let setButton = self.setButton(buttonFrame, tag: 7)
        popupView.addSubview(setButton)
        
        self.showPopupView(popupView)
    }
    
    @IBAction func createButtonClick(sender: AnyObject) {
        
        if self.selectedGroupPosition >= 0 && self.selectedTipoPosition >= 0 {
            self.performSegueWithIdentifier("SoliciatarNext", sender: nil)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let addViewController = segue.destinationViewController as! AddPermisosNextStepViewController
        
        let key = self.groupsData[String.init(format: "%d", self.selectedGroupPosition!)] as! String
        let groups = self.groupsData[key] as! NSMutableArray
        let group = groups[self.selectedTipoPosition!] as! NSDictionary
        
        addViewController.permisos = group
        
        if self.allDay == true {
            addViewController.startDate = self.startDate
            addViewController.endDate =  self.endDate
            addViewController.allDay = self.allDay
            
        }
        else {
            
            addViewController.startDate = self.startTime
            addViewController.endDate =  self.endTime
            addViewController.allDay = self.allDay

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
    
    func loadGroupData() {
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/report", serverDomain)

        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        
        // Setup the session to make REST POST call
        let postParams : [String: AnyObject] = ["sessionInfo": sessionInfo,
                                                "sReportName": "AppPublicPermissionList",
                                                "pPageIni": 1,
                                                "pPageEnd": 1000]
        
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print(postParams)
        } catch {
            print("bad things happened")
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            
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
                    if let result  = jsonData["data"] {
                        
                        for i in 0...result.count - 1 {
                            let dict = (result as! NSArray)[i] as! NSDictionary
                            
                            let groupKey = dict.objectForKey("groupP") as! String
                            if let _ = self.groupsData[groupKey] {
                                
                                let group = self.groupsData[groupKey]! as! NSMutableArray
                                group.addObject(dict)
                            }
                            else {
                                let group = NSMutableArray()
                                group.addObject(dict)
                                self.groupsData[groupKey] = group
                                self.groupsData[String.init(format: "%d", self.groupsData.count/2)] = groupKey
                            }
                        }
                    }
                    
                    self.groupButton.enabled = true
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    // MARK: UITableViewDelegate&DataSource methods
    func fillGroupData(position: Int) {
        
        let key = self.groupsData[String.init(format: "%d", position)] as! String
        self.groupButton .setTitle(key, forState: UIControlState.Normal)
        
        let groups = self.groupsData[key] as! NSMutableArray
        if (groups.count == 1) {
            
            self.selectedTipoPosition = 0

            let group = groups[0] as! NSDictionary
            
            if let _ = group.objectForKey("descr") {
                var descr = group.objectForKey("descr") as! String
                descr = String(descr.characters.first!).capitalizedString + String(descr.characters.dropFirst()).lowercaseString
                self.tipoButton .setTitle(descr, forState: UIControlState.Normal)
                
                if let _ = group.objectForKey("legal") {
                    let legal = group.objectForKey("legal") as! String
                    self.updateInfoButtonWithLegal(legal)
                }
                
                if let _ = group.objectForKey("assignType") {
                    let assignType = group.objectForKey("assignType") as! Int
                    
                    self.timeContainerView.hidden = (assignType == 1)
                    
                    if assignType == 0 {
                        self.allowSelectTime = true
                        self.allDayButton.tag = 0
                        self.allDayButton .setImage(UIImage.init(named: "button_on"), forState: UIControlState.Normal)
                        self.timeTitle.text = "Día completo"
                        self.startTimeButton.hidden = true
                        self.endTimeButton.hidden = true
                        self.allDay = true
                        
                    }
                    else {
                        self.allowSelectTime = false
                        self.allDay = false
                    }
                    
                    self.setOutputFormatter(self.currentYear, day: startDate!.description)
                    self.startDateButton .setTitle(self.outputDateFormatter?.stringFromDate(self.startDate!), forState: UIControlState.Normal)
                    
                    self.setOutputFormatter(self.currentYear, day: endDate!.description)
                    self.endDateButton .setTitle(self.outputDateFormatter?.stringFromDate(self.endDate!), forState: UIControlState.Normal)

                }
            }
            
            self.hideSelectDate(false)

        }
        else {
            self.tipoButton .setTitle("Seleccione un tipo", forState: UIControlState.Normal)
            self.tipoButton.enabled = true
            self.selectedTipoPosition = -1
            self.updateInfoButtonWithLegal("")
            self.hideSelectDate(true)
            self.timeContainerView.hidden = true
        }
    }
    
    func setOutputFormatter(currentYear: Int, day: String) {
        
        if (day.rangeOfString(String.init(format: "%d", currentYear)) != nil) {
            self.outputDateFormatter!.dateFormat = "d MMMM"
        }
        else {
            self.outputDateFormatter!.dateFormat = "yyyy d MMMM"
        }
    }
    
    func setOutputTimeFormatter(currentYear: Int, day: String) {
        
            self.outputDateFormatter!.dateFormat = "HH:mm"
    }

    
    func updateInfoButtonWithLegal(legal: String) {
        if let _ = self.outputDateFormatter {
            
        }
        else {
            self.outputDateFormatter = NSDateFormatter()
        }
        
        if legal.characters.count > 0 {
            self.inforButtonLCWidth.constant = 22
        }
        else {
            self.inforButtonLCWidth.constant = 0
        }
        self.view.layoutIfNeeded()
    }

    func hideSelectDate(value: Bool) {
        self.startDateTitleLabel.hidden = value
        self.endDateTitleLabel.hidden = value
        self.startDateButton.hidden = value
        self.endDateButton.hidden = value
    }
    
    // MARK helper method
    func cancelButton(frame: CGRect, tag: Int) -> UIButton {
        let cancelButton = UIButton.init(type: UIButtonType.Custom)
        cancelButton.frame = frame
        cancelButton .setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        cancelButton.layer.borderWidth = 1
        
        cancelButton.setTitleColor(UIColor.init(32, green: 32, blue: 32), forState: UIControlState.Normal)
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
        cancelButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        cancelButton.tag = tag
        cancelButton.addTarget(self, action: #selector(AddPermisosViewController.datePickerSelected), forControlEvents: .TouchUpInside)
        return cancelButton
    }
    
    func setButton(frame: CGRect, tag: Int) -> UIButton {
        let setButton = UIButton.init(type: UIButtonType.Custom)
        setButton.frame = frame
        setButton .setTitle("Set", forState: UIControlState.Normal)
        setButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        setButton.layer.borderWidth = 1
        
        setButton.setTitleColor(UIColor.init(32, green: 32, blue: 32), forState: UIControlState.Normal)
        setButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
        setButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        setButton.tag = tag
        setButton.addTarget(self, action: #selector(AddPermisosViewController.datePickerSelected), forControlEvents: .TouchUpInside)
        return setButton
    }
    
    
    func showPopupView(view: UIView) {
        
        let config = STZPopupViewConfig.init()
        config.showAnimation = STZPopupShowAnimation.FadeIn
        config.dismissAnimation = STZPopupDismissAnimation.SlideOutToBottom
        
        presentPopupView(view, config: config)
        
    }
    
}

