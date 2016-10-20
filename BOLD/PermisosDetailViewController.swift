//
//  PermisosDetailViewController.swift
//  BOLD
//
//  Created by admin on 6/14/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

protocol PermisosDetailViewControllerDelegate{
    func deletePemisor(controller:PermisosDetailViewController, permisosID:Int)
}

class PermisosDetailViewController: UIViewController{
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeTitleLabel: UILabel!
    @IBOutlet weak var endTimeTitleLabelLCTop: NSLayoutConstraint!

    @IBOutlet weak var endTimeTitleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var changeTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var note1Label: UILabel!
    @IBOutlet weak var note2Label: UILabel!
    @IBOutlet weak var note1TitleLabel: UILabel!
    @IBOutlet weak var note2TitleLabel: UILabel!
    @IBOutlet weak var note2TitleLabelLCTop: NSLayoutConstraint!

    var delegate:PermisosDetailViewControllerDelegate! = nil

    var inputDateFormatter: NSDateFormatter?
    var inputChangeDateFormatter: NSDateFormatter?
    var outputDateFormatter: NSDateFormatter?
    var outputHourFormatter: NSDateFormatter?
    var permisosData: NSDictionary?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.updatePermisosData()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadPermisos()

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
    
    func updatePermisosData() {
        
        self.endTimeTitleLabel.hidden = false
        self.endTimeLabel.hidden = false
        
        self.startTimeTitleLabel.text = "Desde: "
        self.endTimeTitleLabel.text = "Hasta: "
        
        let abbreviation = self.permisosData!.objectForKey("abbreviation") as! String
        let colour = self.permisosData!.objectForKey("colour") as! String
        let idPermisos = self.permisosData!.objectForKey("ID") as! Int

        let name = self.permisosData!.objectForKey("name") as! String
        let stringStartDate = self.permisosData!.objectForKey("startDate") as! String
        let stringEndDate = self.permisosData!.objectForKey("endDate") as! String
        let changeDate = self.permisosData!.objectForKey("changeDate") as! String
        let status = self.permisosData!.objectForKey("status") as! Int
        let isFullDay = self.permisosData!.objectForKey("isFullDay") as! Int

        self.IDLabel.text = String(format: "#%d", idPermisos)
        self.iconLabel.text = abbreviation
        self.iconLabel.backgroundColor = UIColor.init(hexString: colour)
        self.nameLabel.text = name
        
        if let _ = self.permisosData!.objectForKey("NotasEmployee") {
            
            let descPermisos = self.permisosData!.objectForKey("NotasEmployee") as! String
            if descPermisos.characters.count > 0 {

                self.note1Label.text = descPermisos
                self.note1TitleLabel.text = "Employee Notas"
            }
            else {
                self.note1TitleLabel.text = ""
                self.note1Label.text = ""
            }

        }
        else {
            
            self.note1TitleLabel.text = ""
            self.note1Label.text = ""

        }

        if let _ = self.permisosData!.objectForKey("NotasBoss1") {
            
            let descPermisos = self.permisosData!.objectForKey("NotasBoss1") as! String
            if descPermisos.characters.count > 0 {
                
                self.note2Label.text = descPermisos
                self.note2TitleLabel.text = "Boss Notas"
            }
            else {
                
                self.note2TitleLabel.text = ""
                self.note2Label.text = ""
            }
        }
        else {
            
            self.note2TitleLabel.text = ""
            self.note2Label.text = ""
        }
        
        if let _ = self.inputDateFormatter {
            
        }
        else {
            self.inputDateFormatter = NSDateFormatter()
            self.inputChangeDateFormatter = NSDateFormatter()
            self.outputDateFormatter = NSDateFormatter()
            self.outputHourFormatter = NSDateFormatter()
            
            self.inputChangeDateFormatter!.dateFormat = "yyyy-MM-d'T'HH:mm:ss.SSS"
            self.inputDateFormatter!.dateFormat = "yyyy-MM-d'T'HH:mm:ss"
            self.outputDateFormatter!.dateFormat = "dd MMMM"
            self.outputHourFormatter!.dateFormat = "HH:mm"
            
        }
        
        let date = NSDate()
        
        let cal = NSCalendar.currentCalendar()
        let currentYear = cal.component([NSCalendarUnit.Year], fromDate: date)
        
        if isFullDay == 1 {
            
            // Display day only
            if let strDate = self.inputDateFormatter!.dateFromString(stringStartDate) {
                
                self.setOutputFormatter(currentYear, day: stringStartDate)
                self.startTimeLabel.text = self.outputDateFormatter!.stringFromDate(strDate)
            }
            
            if let strDate = self.inputDateFormatter!.dateFromString(stringEndDate) {
                
                self.setOutputFormatter(currentYear, day: stringStartDate)
                self.endTimeLabel.text = self.outputDateFormatter!.stringFromDate(strDate)
            }
            
            if self.startTimeLabel.text == self.endTimeLabel.text {
                
                self.startTimeTitleLabel.text = "Día: "
                
                self.endTimeTitleLabel.hidden = true
                self.endTimeLabel.hidden = true
                self.endTimeTitleLabelLCTop.constant = -16
                self.view.layoutIfNeeded()
            }
        }
        else {
            
            if let startDate = self.inputDateFormatter!.dateFromString(stringStartDate) {
                
                self.setOutputFormatter(currentYear, day: stringStartDate)
                let startDayStr = self.outputDateFormatter!.stringFromDate(startDate)
                
                if let endDate = self.inputDateFormatter!.dateFromString(stringEndDate) {
                    
                    self.setOutputFormatter(currentYear, day: stringStartDate)
                    let endDayDayStr = self.outputDateFormatter!.stringFromDate(endDate)
                    
                    if (startDayStr == endDayDayStr) {
                        
                        self.startTimeLabel.text = self.outputDateFormatter!.stringFromDate(startDate)
                        self.endTimeLabel.text = String.init(format: "%@ - %@", self.outputHourFormatter!.stringFromDate(startDate), self.outputHourFormatter!.stringFromDate(endDate))
                        self.startTimeTitleLabel.text = "Día: "
                        self.endTimeTitleLabel.text = "Horas: "
                        
                    }
                    else {
                        
                        self.startTimeLabel.text = String.init(format: "%@ - %@", startDayStr, self.outputHourFormatter!.stringFromDate(startDate))
                        self.endTimeLabel.text = String.init(format: "%@ - %@", endDayDayStr, self.outputHourFormatter!.stringFromDate(endDate))
                        
                    }
                }
            }
        }
        
        if let strDate = self.inputChangeDateFormatter!.dateFromString(changeDate) {
            self.setOutputFormatter(currentYear, day: changeDate)
            
            if strDate.isToday() {
                self.changeTimeLabel.text = "Hoy"
            }
            else if strDate.isYesterday() {
                self.changeTimeLabel.text = "Ayer"
            }
            else {
                self.changeTimeLabel.text = self.outputDateFormatter!.stringFromDate(strDate)
            }
        }
        
        switch status {
        case 0:
            self.statusLabel.text = " Pendiente  "
            self.statusLabel.backgroundColor = UIColor.init(0, green: 135, blue: 255)
//            self.deleteButton.hidden = false
            self.deleteButton.hidden = true
            break;
        case 1:
            self.statusLabel.text = " Denegado  "
            self.statusLabel.backgroundColor = UIColor.init(204, green: 45, blue: 41)
            self.deleteButton.hidden = true

            break;
            
        default:
            self.statusLabel.text = " Aprobado  "
            self.statusLabel.backgroundColor = UIColor.init(55, green: 152, blue: 36)
            self.deleteButton.hidden = true

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
    @IBAction func deleteButtonClick(sender: AnyObject) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: "Se va a eliminar la solicitud. ¿Está seguro?", preferredStyle: .Alert)
        
        // Create and add the OK action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in
        }
        actionSheetController.addAction(cancelAction)

        let okAction: UIAlertAction = UIAlertAction(title: "Eliminar", style: .Default) { action -> Void in
            // Do some stuff
            
//            self.deletePermisos()
            let idPermisos = self.permisosData!.objectForKey("ID") as! Int

            self.delegate .deletePemisor(self, permisosID: idPermisos)
            self.navigationController?.popViewControllerAnimated(true)
            
        }
        actionSheetController.addAction(okAction)

        // Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)

    }

    
    func deletePermisos() {
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/report", serverDomain)
        
        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        
        // Setup the session to make REST POST call
        let postParams : [String: AnyObject] = ["sessionInfo": sessionInfo,
                                                "sReportName": "AppFormPermissionListPending"]
        
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
                        
                    }
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    
    func loadPermisos() {
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/report", serverDomain)
        
        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        let idPermisos = self.permisosData!.objectForKey("ID") as! Int

        // Setup the session to make REST POST call
        let postParams : [String: AnyObject] = ["sessionInfo": sessionInfo,
                                                "sReportName": "AppPermissionDetailedInformation",
                                                "pID": idPermisos]
        
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
                    if let _  = jsonData["data"] {
                        self.permisosData = (jsonData["data"] as! NSArray)[0] as? NSDictionary
                        self.updatePermisosData()
                    }
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func setOutputFormatter(currentYear: Int, day: String) {
        
        if (day.rangeOfString(String.init(format: "%d", currentYear)) != nil) {
            self.outputDateFormatter!.dateFormat = "d MMMM"
        }
        else {
            self.outputDateFormatter!.dateFormat = "yyyy d MMMM"
        }
    }

}
