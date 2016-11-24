

//
//  AddPermisosNextStepViewController.swift
//  BOLD
//
//  Created by admin on 6/14/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import STZPopupView
import Fabric
import Crashlytics

class AddPermisosNextStepViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeTitleLabel: UILabel!
    @IBOutlet weak var endTimeTitleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var addButtonLCWidth: NSLayoutConstraint!

    var outputDateFormatter: NSDateFormatter?

    var permisos = NSDictionary()
    var startDate: NSDate?
    var endDate: NSDate?
    var allDay: Bool?

    var comment = ""
    var textField: UITextField?
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationView.backgroundColor = bgNavigationColor

        let abbreviation = permisos.objectForKey("abr") as! String
        let colour = permisos.objectForKey("color") as! String
        let name = permisos.objectForKey("descr") as! String

        self.iconLabel.text = abbreviation
        self.iconLabel.backgroundColor = UIColor.init(hexString: colour)
        self.nameLabel.text = name
        
        self.outputDateFormatter = NSDateFormatter()
        self.createButton.backgroundColor = bgNavigationColor

        let cal = NSCalendar.currentCalendar()
        let currentYear = cal.component([NSCalendarUnit.Year], fromDate: NSDate())

        let assignType = permisos.objectForKey("assignType") as! Int
        
        if self.startDate!.compare(self.endDate!) == NSComparisonResult.OrderedDescending {
            self.endDate = self.endDate!.dateByAddingDays(1)
        }
        
        if self.allDay == true || assignType == 1{
            if (self.startDate?.description.rangeOfString(String.init(format: "%d", currentYear)) != nil) {
                self.outputDateFormatter!.dateFormat = "d MMMM"
            }
            else {
                self.outputDateFormatter!.dateFormat = "yyyy d MMMM"
            }
            self.startTimeLabel.text = self.outputDateFormatter?.stringFromDate(self.startDate!)

            if (self.endDate?.description.rangeOfString(String.init(format: "%d", currentYear)) != nil) {
                self.outputDateFormatter!.dateFormat = "d MMMM"
            }
            else {
                self.outputDateFormatter!.dateFormat = "yyyy d MMMM"
            }
            self.endTimeLabel.text = self.outputDateFormatter?.stringFromDate(endDate!)
        }
        else {
            
            if (self.startDate?.description.rangeOfString(String.init(format: "%d", currentYear)) != nil) {
                self.outputDateFormatter!.dateFormat = "d MMMM HH:mm"
            }
            else {
                self.outputDateFormatter!.dateFormat = "yyyy d MMMM HH:mm"
            }
            self.startTimeLabel.text = self.outputDateFormatter?.stringFromDate(self.startDate!)
            
            if (self.endDate?.description.rangeOfString(String.init(format: "%d", currentYear)) != nil) {
                self.outputDateFormatter!.dateFormat = "d MMMM HH:mm"
            }
            else {
                self.outputDateFormatter!.dateFormat = "yyyy d MMMM HH:mm"
            }
            self.endTimeLabel.text = self.outputDateFormatter?.stringFromDate(endDate!)
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
    
    @IBAction func descriptionButtonClick(sender: AnyObject) {

        let popupView = UIView()
        popupView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 20, 160)
        popupView.backgroundColor = UIColor.whiteColor()
        
        let label = UILabel()
        label.textColor = UIColor.init(32, green: 32, blue: 32)
        label.frame = CGRectMake(10, 0, popupView.frame.size.width - 20, 40)
        label.font = UIFont.boldSystemFontOfSize(15)
        label.textAlignment = NSTextAlignment.Left
        label.text = "Anadir una nota"
        popupView.addSubview(label)
        
        var frame = CGRectMake(10.0, 40 , popupView.frame.size.width - 20, 60)
        let textField = UITextField.init(frame: frame)
        textField.borderStyle = UITextBorderStyle.Line
        textField.returnKeyType = UIReturnKeyType.Done
        textField.font = UIFont.systemFontOfSize(15)

        self.textField = textField
        textField.delegate = self
        
        popupView.addSubview(textField)
        
        frame = CGRectMake(110.0, 110 , (popupView.frame.size.width - 100 - 20) / 2, 40)
        let cancelButton = self.cancelButton(frame, tag: 0)
        popupView.addSubview(cancelButton)
        
        frame = CGRectMake(110.0 + (popupView.frame.size.width - 100 - 20) / 2, 110 , (popupView.frame.size.width - 100 - 20) / 2, 40)
        let acceptButton = self.acceptButton(frame, tag: 1)
        popupView.addSubview(acceptButton)

        self.showPopupView(popupView)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textField!.resignFirstResponder()
        
        return false
    }

    
    // MARK helper method
    func cancelButton(frame: CGRect, tag: Int) -> UIButton {
        let cancelButton = UIButton.init(type: UIButtonType.Custom)
        cancelButton.frame = frame
        cancelButton .setTitle("CANCELAR", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.init(0, green: 150, blue: 136), forState: UIControlState.Normal)
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
        cancelButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        cancelButton.tag = tag
        cancelButton.addTarget(self, action: #selector(AddPermisosNextStepViewController.buttonClick), forControlEvents: .TouchUpInside)
        return cancelButton
    }
    
    func acceptButton(frame: CGRect, tag: Int) -> UIButton {
        let setButton = UIButton.init(type: UIButtonType.Custom)
        setButton.frame = frame
        setButton .setTitle("GUARDAR", forState: UIControlState.Normal)
        setButton.setTitleColor(UIColor.init(0, green: 150, blue: 136), forState: UIControlState.Normal)
        setButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center;
        setButton.titleLabel?.font = UIFont.boldSystemFontOfSize(13)
        setButton.tag = tag
        setButton.addTarget(self, action: #selector(AddPermisosNextStepViewController.buttonClick), forControlEvents: .TouchUpInside)
        return setButton
    }
    
    func buttonClick(sender: AnyObject) {
        let button = sender as! UIButton
        
        dismissPopupView()
        
        switch button.tag {
        case 1:
            if let _ = self.textField!.text {
                self.comment = self.textField!.text!
                self.descriptionButton .setTitle(self.textField!.text, forState: UIControlState.Normal)
                self.addButtonLCWidth.constant = 0
                self.view .layoutIfNeeded()
            }
            break;
        default:
            break;
        }
    }

    @IBAction func createButtonClick(sender: AnyObject) {
        self .addItemData()
    }
    
    func addItemData() {
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/requestPermission", serverDomain)

        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        
        self.outputDateFormatter!.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        // Setup the session to make REST POST call
        let postParams : [String: AnyObject] = ["sessionInfo": sessionInfo,
                                                "idIncidence": self.permisos.objectForKey("ID")!,
                                                "iniDatestr": self.outputDateFormatter!.stringFromDate(self.startDate!),
                                                "endDatestr": self.outputDateFormatter!.stringFromDate(self.endDate!),
                                                "employeeComments": self.comment]
        
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
                    if let _ = jsonData["err"] {
                        let errMessage = jsonData["err"] as! String
                        dispatch_async(dispatch_get_main_queue(), {
                            Answers.logCustomEventWithName("requestPermissionFailed", customAttributes: nil)
                            
                            self.showErrorMessage(errMessage)
                        })
                    }
                    else {
                        Answers.logCustomEventWithName("requestPermissionOK", customAttributes: nil)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            
                            let viewcontroller = self.navigationController?.viewControllers.first
                            let str =  NSStringFromClass(viewcontroller!.dynamicType).componentsSeparatedByString(".").last!
                            
                            if str == "PermisosViewController" {
                                self.navigationController!.popToRootViewControllerAnimated(true)

                            }
                            else {

//                                self.navigationController!.popToRootViewControllerAnimated(true)
                                
                                let destViewController = self.mainStoryboard.instantiateViewControllerWithIdentifier("permisos")
                                self.navigationController! .pushViewController(destViewController, animated: true)

                            }
                            
                        })
                    }
                }
            } catch {
                print(error)
                
            }
        }
        
        task.resume()
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
    
    func showPopupView(view: UIView) {
        
        let config = STZPopupViewConfig.init()
        config.showAnimation = STZPopupShowAnimation.FadeIn
        config.dismissAnimation = STZPopupDismissAnimation.SlideOutToBottom
        
        presentPopupView(view, config: config)
        
    }

}

extension String {

    func stringHeightWidth(fontSize:CGFloat, width:CGFloat) -> CGFloat {
        let font = UIFont.systemFontOfSize(fontSize)
        let size = CGSizeMake(width,CGFloat.max)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        
        let attributes = [NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        
        return rect.size.height
    }
}

