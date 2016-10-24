//
//  AppDelegate.swift
//  BOLD
//
//  Created by admin on 6/3/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit
import Foundation

var fullname = ""
var user = ""
var sessionInfo = NSDictionary()
var monthlycache : NSMutableArray = []
var bgNavigationColor = UIColor()
var bgMainColor = UIColor()
var logoName = String()

var serverDomain = String()
var allPermisosData: [NSNumber: Int] = [:]
var changedPermisosIds: [NSNumber] = []

var timer = NSTimer()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Get user setting variable from user setting.
        serverDomain = NSBundle.mainBundle().objectForInfoDictionaryKey("WEB_SERVICE_BASE_URL") as! String

        var color = NSBundle.mainBundle().objectForInfoDictionaryKey("BG_NAVIGATION_COLOR") as! String
        bgNavigationColor = UIColor.init(hexString: color)

        color = NSBundle.mainBundle().objectForInfoDictionaryKey("BG_MAIN_COLOR") as! String
        bgMainColor = UIColor.init(hexString: color)
        
        logoName = NSBundle.mainBundle().objectForInfoDictionaryKey("BG_LOGO_NAME") as! String
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        
        // Timer work each 6 hours
//        timer = NSTimer.scheduledTimerWithTimeInterval(6 * 60 * 60, target: self, selector: #selector(loadPermissionData), userInfo: nil, repeats: true)

        // TODO: FOR DEMO MODE
        timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(loadPermissionData), userInfo: nil, repeats: true)

//        if let _ = launchOptions {
//            if let result = launchOptions![UIApplicationLaunchOptionsLocalNotificationKey]{
//                
//                print(result)
//                
//            }
//        }
        return true
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        NSNotificationCenter.defaultCenter().postNotificationName("PermisosListShouldRefresh", object: self)
        
        if application.applicationState == .Inactive {
            
            let userInfo = notification.userInfo! as NSDictionary
            if let _ = userInfo["eventIds"] {
                changedPermisosIds = userInfo["eventIds"] as! [NSNumber]
                print(changedPermisosIds)
                self.showPermisosViewController()
            }
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
//        NSNotificationCenter.defaultCenter().postNotificationName("PermisosListShouldRefresh", object: self)
        
        // Re-login again.
        
        self.autoLogin()
        
    }
    
    func autoLogin()
    {
        let ud = NSUserDefaults.standardUserDefaults()
        let username = ud.objectForKey(kBoldUsername) as? String
        let password = ud.objectForKey(kBoldPassword) as? String
        
        if username != nil && password != nil {
            
            let serverEndPoint = String.init(format: "%@/gpsnode/authenticate", serverDomain)
            var workid = -1
            if username != "" && password != "" {
                
                let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
                // Setup the session to make REST POST call
                let postParams : [String: AnyObject] = ["user": username!, "password":password!, "deviceID":"BOLDApp", "clientCode":"100001"]
                
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
                        }
                        else {
                            
                            // TODO: show login view controller
                        }
                    })
                    
                }
                task.resume()
                
            }
            else{
                
                // TODO: show login view controller
                return;
            }
        }

    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }


    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func loadPermissionData() {
        
        if sessionInfo.count == 0 {
            return;
        }
        
        let serverEndPoint = String.init(format: "%@/gpsnode/mobile/ws/report", serverDomain)
        
        let request = NSMutableURLRequest(URL: NSURL(string: serverEndPoint)!)
        
        // Setup the session to make REST POST call
        let postParams : [String: AnyObject] = ["sessionInfo": sessionInfo,
                                                "sReportName": "AppFormPermissionListPending",
                                                "pPageIni": 1,
                                                "pPageEnd": 1000]
        
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
//            print(postParams)
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
                        
                        let newPermisosData = jsonData["data"] as? [NSDictionary]
                        
                        self.filterUpdateStatusEvent(newPermisosData!)
                        self.savePermisorData(newPermisosData!)
                        
                    }
                }
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    func savePermisorData(permisosData: [NSDictionary]) {
        
        allPermisosData.removeAll()
        let permisosDataCount = permisosData.count
        if (permisosDataCount == 0){
            return;
        }
        for i in 0...permisosData.count - 1 {
            
            let data = permisosData[i] as NSDictionary
            
            let eventId = data.objectForKey("ID") as! NSNumber
            let status = data.objectForKey("status") as! Int
            
//            print("\(eventId): \(status)")
            
            allPermisosData.updateValue(status, forKey: eventId)
        }
    }
    
    func filterUpdateStatusEvent(newPermisosData: [NSDictionary]) {
        
        if allPermisosData.count > 0 {
            
            // Check in case we save the data already.
            if allPermisosData.count == 0 {
                return
            }
            
            var changedEvent = [NSDictionary]()
            
            for i in 0...newPermisosData.count - 1 {
                
                let data = newPermisosData[i] as NSDictionary
                
                let eventId = data.objectForKey("ID") as! NSNumber
                let status = data.objectForKey("status") as! Int
                
                if let _ = allPermisosData[eventId] {
                    
                    let oldStatus = allPermisosData[eventId]

                    // TODO: change condition for real event change
                    if status > 0 && status != oldStatus {
                        changedEvent .append(data)
                    }
                    
//                     DEMO code
//                    if newStatus > 0 && changedEvent.count < 1 {
//                        changedEvent .append(data)
//                    }
                }
            }
            
            if (changedEvent.count > 0) {
                
                var count = 0
                var eventIds = [NSNumber]()
                var message = String()
                
                for i in 0...changedEvent.count - 1 {
                    let data = changedEvent[i] as NSDictionary
                    let eventId = data.objectForKey("ID") as! NSNumber
                    let status = data.objectForKey("status") as! Int
                    let eventName = data.objectForKey("name") as! String
                    let startDate = data.objectForKey("startDate") as! String
                    
                    eventIds .append(eventId)
                    
                    let strStatus = status == 1 ? "denegado": "aprobado"
                    
                    if count < 1 {
                        message += "\(eventName) del día \(self.dateWithFormatFromDate(startDate)) ha sido \(strStatus) "
                    }
                    else if count == 1 {
                        message += "and \(changedEvent.count - count) more ..."
                    }
                    
                    count += 1
                }
                
                let localNotification = UILocalNotification()
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
                localNotification.alertBody = message
                localNotification.userInfo = ["eventIds": eventIds]
                localNotification.timeZone = NSTimeZone.defaultTimeZone()
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)

            }
        }
    }
    
    
    func showPermisosViewController() {
        let vc = self.window?.rootViewController
        if vc!.isKindOfClass(UINavigationController) {
            let nc = vc as!UINavigationController
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            let destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("permisos") as!PermisosViewController
            
            if let _ = nc.presentedViewController {
                
                let displayVC = nc.presentedViewController as! UINavigationController
                
                displayVC.topViewController?.sideMenuController()!.setContentViewController(destViewController)
            }
        }
    }
    
    // Helper method.
    func dateWithFormatFromDate(inputDate: String) -> String{
        
        let date = NSDate()
        let cal = NSCalendar.currentCalendar()
        let currentYear = cal.component([NSCalendarUnit.Year], fromDate: date)
        
        let inputDateFormatter = NSDateFormatter()
        let outputDateFormatter = NSDateFormatter()
        
        inputDateFormatter.dateFormat = "yyyy-MM-d'T'HH:mm:ss"
        var dateStr = ""
        
        if let strDate = inputDateFormatter.dateFromString(inputDate) {
            
            if (inputDate.rangeOfString(String.init(format: "%d", currentYear)) != nil) {
                outputDateFormatter.dateFormat = "d 'de' MMMM"
            }
            else {
                outputDateFormatter.dateFormat = "yyyy d 'de' MMMM"
            }
            
            dateStr = outputDateFormatter.stringFromDate(strDate)
        }
        return dateStr
    }
    
}
