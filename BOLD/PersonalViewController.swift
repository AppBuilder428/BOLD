//
//  PersonalViewController.swift
//  BOLD
//
//  Created by admin on 6/14/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadImageFrom(link link:String, contentMode: UIViewContentMode) {
        NSURLSession.sharedSession().dataTaskWithURL( NSURL(string:link)!, completionHandler: {
            (data, response, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}

class PersonalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewLCWidth: NSLayoutConstraint!
    @IBOutlet weak var contentViewLCHeight: NSLayoutConstraint!

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var bgHeaderView: UIImageView!
    
    @IBOutlet weak var nametxt: UILabel!
    @IBOutlet weak var DNI: UILabel!
    @IBOutlet weak var colegiado: UILabel!
    @IBOutlet weak var profesional: UILabel!
    
    @IBOutlet weak var Fecha: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var cards = NSMutableArray()
    var headers = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationView.backgroundColor = bgNavigationColor
        self.scrollview.backgroundColor = bgMainColor
        self.contentView.backgroundColor = bgMainColor
        self.tableView.backgroundColor = bgMainColor

        // Do any additional setup after loading the view.
        img.layer.borderWidth = 1
        img.layer.masksToBounds = false
        img.layer.borderColor = UIColor.grayColor().CGColor
        img.layer.cornerRadius = img.frame.height/2
        img.clipsToBounds = true
        self.scrollview.contentSize.height = 820;
        self.tableView.scrollEnabled = false
        self.loadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.contentViewLCWidth.constant = CGRectGetWidth(UIScreen.mainScreen().bounds)
        self.scrollview .layoutIfNeeded()
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
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func loadData() {
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/personalData", serverDomain)

        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        let postParams : [String: AnyObject] = ["sessionInfo":sessionInfo]
        
        // Create the request
        //            let request = NSMutableURLRequest(URL: url)
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
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if (jsonData["ok"] as! Bool == true ){
                            
                            let headers = jsonData["data"]!["header"]! as! NSArray

                            self.headers = NSMutableArray.init(array: headers)

                            if (self.headers.count <= 4) {
                                self.bgHeaderView.image = UIImage.init(named: "bg_border_all")
                            }
                            
                            let headerdata = jsonData["data"]!["header"]! as! NSArray
                            
                            var count = 0 as Int
                            for data in headerdata {
//                                let title = data.objectForKey("title") as! String
                                let val = data.objectForKey("value") as! String
                                
//                                print(title)
                                switch (count) {
                                case 0 :
                                    self.nametxt.text = val
                                case 1 :
                                    self.DNI.text = val
                                case 2:
                                    self.colegiado.text = val
                                case 3:
                                    self.profesional.text = val
                                default: break
                                }
                                count = count + 1
                            }
                            
                            let carddsata = jsonData["data"]!["cards"]! as! NSArray
                            self.cards = NSMutableArray.init(array: carddsata)
                            self.tableView .reloadData()
                            
                            var itemCount = 0;
                            for data in carddsata {
                                let vals = data.objectForKey("values") as! NSArray
                                itemCount += vals.count;
                            }
                            
                            let height = CGFloat(carddsata.count * 50 + itemCount * 60 + max(self.headers.count - 4, 0) * 60) + 145
                            self.contentViewLCHeight.constant = height
                            self.scrollview.layoutIfNeeded()
                            
                            if let workerID = sessionInfo["workerID"] {
                                
                                // Lazy load the image using lazy load.
                                let str = "\(serverDomain)/gpsnode/mobile/ws/cachedPhoto/\(workerID)"
                                self.img.downloadImageFrom(link: str, contentMode: UIViewContentMode.ScaleAspectFit)  //set your image from link array.

                                //                            print("http://soporte.gps-plan.com/gpsnode/mobile/ws/cachedPhoto/\(workerID)")
                                //                            if let url = NSURL(string: "http://soporte.gps-plan.com/gpsnode/mobile/ws/cachedPhoto/\(workerID)") {
                                //                                if let data = NSData(contentsOfURL: url) {
                                //                                    self.img.image = UIImage(data: data)
                                //                                }        
                                //                            }

                            }
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
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cards.count + 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return max(self.headers.count - 4, 0)
        }
        else {
            if self.cards.count > 0 {
                let dict = self.cards[section - 1]
                let vals = dict.objectForKey("values") as! NSArray
                return vals.count + 1
            }
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == 0) {
            return 60
        }
        else {
            if indexPath.row == 0 {
                return 50
            }
            else {
                return 60
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell:CardTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CardTableViewCell
            let data = self.headers[indexPath.row + 4]
            let title = data.objectForKey("title") as! String
            let val = data.objectForKey("value") as! String
            
            cell.cardTitleLabel?.text = title
            cell.cardValueLabel?.text = val
            cell.selectionStyle = .None
            cell.contentView.backgroundColor = bgMainColor

            if (indexPath.row + 4 == self.headers.count - 1) {
                cell.cardBGView.image = UIImage(named: "bg_border_bottom")!
            }
            else {
                cell.cardBGView.image = UIImage(named: "bg_border_middle")!
            }
            return cell
        }
        else {
            if indexPath.row == 0 {
                let cell:CardTitleTableViewCell = tableView.dequeueReusableCellWithIdentifier("TitleCell", forIndexPath: indexPath) as! CardTitleTableViewCell
                let dict = self.cards[indexPath.section - 1]
                let cardName = dict.objectForKey("cardName") as! NSString
                
                cell.cardTitleLabel?.text = cardName as String
                cell.selectionStyle = .None
                cell.contentView.backgroundColor = bgMainColor
                
                return cell
            }
            else {
                
                let cell:CardTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CardTableViewCell
                let dict = self.cards[indexPath.section - 1]
                let vals = dict.objectForKey("values") as! NSArray
                let data = vals[indexPath.row - 1]
                
                let title = data.objectForKey("title") as! String
                let val = data.objectForKey("value") as! String
                
                cell.cardTitleLabel?.text = title
                cell.cardValueLabel?.text = val
                cell.selectionStyle = .None
                cell.contentView.backgroundColor = bgMainColor

                if (indexPath.row == vals.count) {
                    cell.cardBGView.image = UIImage(named: "bg_border_bottom")!
                }
                else {
                    cell.cardBGView.image = UIImage(named: "bg_border_middle")!
                }

                return cell
            }
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
