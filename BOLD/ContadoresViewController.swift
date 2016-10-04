//
//  ContadoresViewController.swift
//  BOLD
//
//  Created by admin on 6/14/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class ContadoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var yearPickerViewLCBottom: NSLayoutConstraint!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var contadoresYear = NSMutableArray()
    var contadores = NSMutableArray()
    var showPickerView: Bool = false
    var currentYear: Int = 0
    var selectedPosition: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationView.backgroundColor = bgNavigationColor

        // Do any additional setup after loading the view.
        self.dataForCalendar()
        self.addDoneButtonInToolBar()
        self.showPickerView = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let cal = NSCalendar.currentCalendar()
        let curYear = cal.component([NSCalendarUnit.Year], fromDate: NSDate())
        let str = String.init(format: "%d", curYear)
        
        self.yearLabel.text = str
        self.loadDataWithYear(str)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dataForCalendar()
    {
        let cal = NSCalendar.currentCalendar()
        let currentYear = cal.component([NSCalendarUnit.Year], fromDate: NSDate())

        for i in -20...20 {
            let str = String.init(format: "%d", (i + currentYear))
            self.contadoresYear .addObject(str)
        }
        
        self.selectedPosition = 20
    }
    
    func addDoneButtonInToolBar()
    {
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(ContadoresViewController.donePressed))
        self.toolBar.setItems([flexButton, doneButton], animated: true)
        self.toolBar.sizeToFit()

    }
    
    
    func addListYear() {
        
        self.showPickerView = !self.showPickerView
        
        if self.showPickerView == true {
            
            self.yearPickerViewLCBottom.constant = 0
            self.view.layoutIfNeeded()
        }
        else {
            self.yearPickerViewLCBottom.constant = -216
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func BackBtn(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("mainview1")
        sideMenuController()?.setContentViewController(destViewController)
    }

    func donePressed() {
        
        self.selectedPosition = self.yearPickerView.selectedRowInComponent(0)
        
        let selectedYear = self.contadoresYear[self.selectedPosition] as! String
        self.yearLabel.text = selectedYear
        self.loadDataWithYear(selectedYear)
        
        self.hideYearPickerView()
        
    }

    @IBAction func calendarButtonLick(sender: AnyObject) {
        
        self.showYearPickerView();
    }

    func showYearPickerView()
    {
        if self.showPickerView == false {
            
            self.showPickerView = true

            UIView .animateWithDuration(0.2, animations: {
                
                self.view.userInteractionEnabled = false
                self.yearPickerViewLCBottom.constant = 0
                self.yearPickerView.selectRow(self.selectedPosition, inComponent: 0, animated: false)
                
                self.view .layoutIfNeeded()

                }, completion: { (Bool) in
                    self.view.userInteractionEnabled = true
            })
        }
    }
    
    func hideYearPickerView()
    {
        if self.showPickerView == true {
            
            self.showPickerView = false
            
            UIView .animateWithDuration(0.1, animations: {
                
                self.view.userInteractionEnabled = false
                self.yearPickerViewLCBottom.constant = -216 - 44
                self.view .layoutIfNeeded()
                
                }, completion: { (Bool) in
                    self.view.userInteractionEnabled = true
            })
        }
    }

    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func loadDataWithYear(year: NSString) {
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/personalCounters", serverDomain)
        
        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        let postParams : [String: AnyObject] = ["sessionInfo":sessionInfo, "iYear": year]
        
        // Create the request
        //            let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        self.indicator .startAnimating()
        
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
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if (jsonData["ok"] as! Bool == true ){
                            let contadoresData = jsonData["data"]! as! NSMutableArray
                            self.contadores = contadoresData

                            self.tableView .reloadData()
                        }
                    })
                    
                }
            } catch {
                print(error)
            }
        }
        task.resume()
        
    }
    
    // MARK: UITableViewDelegate&DataSource methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.contadores.count > 0 {
            return self.contadores.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:ContadoresTableViewCell = tableView.dequeueReusableCellWithIdentifier("ContadoresCell", forIndexPath: indexPath) as! ContadoresTableViewCell
        let dict = self.contadores[indexPath.row] as! NSDictionary
        cell.setContadore(dict )
        
        return cell
    }
    
    // MARK: - Picker view delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.contadoresYear.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.contadoresYear[row] as! String
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
