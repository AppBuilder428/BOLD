//
//  LoginViewController.swift
//  BOLD
//
//  Created by admin on 6/3/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import Crashlytics

let kBoldUsername:String = "BOLDUsername"
let kBoldPassword:String = "BOLDPassword"

class LoginViewController: UIViewController {

    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var saveAccountButton: UIButton!

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var savePassword: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        self.statusView.backgroundColor = bgNavigationColor
        self.backgroundView.backgroundColor = bgMainColor
        self.loginButton.backgroundColor = bgNavigationColor
        self.logoImageView.image = UIImage.init(named: String.init(format: "%@.png", logoName))

        user = ""
        fullname = ""
        
        let ud = NSUserDefaults.standardUserDefaults()
        let username = ud.objectForKey(kBoldUsername) as? String
        let password = ud.objectForKey(kBoldPassword) as? String
        
        self.usernametxt.text = username
        self.passwordtxt.text = password
        
        if username != nil && password != nil {
            self.savePassword = true
            
            self.saveAccountButton.setImage(UIImage.init(named: "icon_checked"), forState: UIControlState.Normal)

            self.enterButton(self)
        }
        else {
            self.savePassword = false
            
            self.saveAccountButton.setImage(UIImage.init(named: "icon_uncheck"), forState: UIControlState.Normal)
        }
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let ud = NSUserDefaults.standardUserDefaults()
        let username = ud.objectForKey(kBoldUsername) as? String
        let password = ud.objectForKey(kBoldPassword) as? String
        
        self.usernametxt.text = username
        self.passwordtxt.text = password
        
        if username != nil && password != nil {
            self.savePassword = true
            
            self.saveAccountButton.setImage(UIImage.init(named: "icon_checked"), forState: UIControlState.Normal)
            
            self.enterButton(self)
        }
        else {
            self.savePassword = false
            
            self.saveAccountButton.setImage(UIImage.init(named: "icon_uncheck"), forState: UIControlState.Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func saveAccountButtonClickButton(sender: AnyObject) {
        
        self.savePassword = !self.savePassword;
        
        if (self.savePassword == true) {
            self.saveAccountButton.setImage(UIImage.init(named: "icon_checked"), forState: UIControlState.Normal)
        }
        else {
            self.saveAccountButton.setImage(UIImage.init(named: "icon_uncheck"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func enterButton(sender: AnyObject) {
        
        let serverEndPoint = String.init(format: "%@/gpsnode/authenticate", serverDomain)
        let username = usernametxt.text! as String
        let password = passwordtxt.text! as String
        var workid = -1
        if username != "" && password != "" {
            
            let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
            // Setup the session to make REST POST call
            let postParams : [String: AnyObject] = ["user": username, "password":password, "deviceID":"BOLDApp", "clientCode":"100001"]
            
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
            
            self.indicator .startAnimating()

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
                        sessionInfo = jsonData
                        
                        if jsonData["user"] != nil {
                            workid = jsonData["workerID"] as! Int
                            user = jsonData["user"] as! String
                            fullname = jsonData["fullName"] as! String
                            
                            if (self.savePassword == true) {
                                let ud = NSUserDefaults.standardUserDefaults()
                                ud.setObject(username, forKey: kBoldUsername)
                                ud.setObject(password, forKey: kBoldPassword)
                                ud.synchronize()
                            }
                            else {
                                
                                let ud = NSUserDefaults.standardUserDefaults()
                                ud.setObject(nil, forKey: kBoldPassword)
                                ud.synchronize()
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    timerActive?.invalidate()
                                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                    
//                                    timerActive = NSTimer.scheduledTimerWithTimeInterval(5 * 60 * 60, target: appDelegate, selector: #selector(AppDelegate.showLoginView), userInfo: nil, repeats: false)
                                      timerActive = NSTimer.scheduledTimerWithTimeInterval(5*60, target: appDelegate, selector: #selector(AppDelegate.showLoginView), userInfo: nil, repeats: false)
                                })
                            }
                        }
                    }
                } catch {
                    print(error)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    print(workid)
                    if workid >= 0 {
                        // Masquer l'icône de chargement dans la barre de status
                        Answers.logLoginWithMethod("Manual",
                            success: true,
                            customAttributes: nil)
                        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("mainview") as UIViewController
                        self.presentViewController(viewController, animated: true, completion: nil)
                    }
                    else {
                        Answers.logLoginWithMethod("Manual",
                            success: false,
                            customAttributes: nil)
                        let checkfailed = UIAlertController(title: "Input Error", message: "Username or Password is invalid", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        checkfailed.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        
                        self.presentViewController(checkfailed, animated: true, completion: nil)
                        return;
                    }
                })
                
            }
            task.resume()
            
        }
        else{
            let checkfailed = UIAlertController(title: "Input Error", message: "All fields are required!", preferredStyle: UIAlertControllerStyle.Alert)
            
            checkfailed.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(checkfailed, animated: true, completion: nil)
            return;
        }
    }

    
//    func makeHTTPPostRequest(path: String, body: [String: AnyObject], onCompletion: ServiceResponse) {
//        var err: NSError?
//        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
//        
//        // Set the method to POST
//        request.HTTPMethod = "POST"
//        
//        // Set the POST body for the request
//        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
//        let session = NSURLSession.sharedSession()
//        
//        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//            let json:JSON = JSON(data: data)
//            onCompletion(json, err)
//        })
//        task.resume()
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
