//
//  SiteViewController.swift
//  BOLD
//
//  Created by admin on 6/16/16.
//  Copyright © 2016 admin. All rights reserved.
//

import UIKit

class SiteViewController: UIViewController {

    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationView.backgroundColor = bgNavigationColor

        // Do any additional setup after loading the view.
        let url = "http://www.gps-plan.com"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webview.loadRequest(request)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
