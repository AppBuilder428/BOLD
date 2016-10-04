//
//  LoginViewController.swift
//  BOLD
//
//  Created by admin on 6/3/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        self.statusView.backgroundColor = bgNavigationColor
        self.backgroundView.backgroundColor = bgMainColor
        
        user = ""
        fullname = ""
        
                usernametxt.text = "testapp"
                passwordtxt.text = "testapp"

        // Do any additional setup after loading the view.
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
    
    @IBAction func enterButton(sender: AnyObject) {
        
//        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("mainview") as UIViewController
//        self.presentViewController(viewController, animated: true, completion: nil)
//        return
        
//        usernametxt.text = "testapp"
//        passwordtxt.text = "testapp"

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
                        sessionInfo = jsonData
                    
                        if jsonData["user"] != nil {
                            workid = jsonData["workerID"] as! Int
                            user = jsonData["user"] as! String
                            fullname = jsonData["fullName"] as! String
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
                    
                    
                    
                        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("mainview") as UIViewController
                        self.presentViewController(viewController, animated: true, completion: nil)
                    }
                    else {
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
