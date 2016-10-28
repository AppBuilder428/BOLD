import UIKit
import Foundation

@objc(MyApplication) class MyApplication: UIApplication {
    

    override func sendEvent(event: UIEvent) {
        //
        // Ignore .Motion and .RemoteControl event
        // simply everything else then .Touches
        //
        if event.type != .Touches {
            super.sendEvent(event)
            return
        }
        
        //
        // .Touches only
        //
        var restartTimer = true
        
        if let touches = event.allTouches() {
            //
            // At least one touch in progress?
            // Do not restart auto lock timer, just invalidate it
            //
            for touch in touches.enumerate() {
                if touch.element.phase != .Cancelled && touch.element.phase != .Ended {
                    restartTimer = false
                    break
                }
            }
        }
        
        if restartTimer {
            // Touches ended || cancelled, restart auto lock timer
            if let _ = timerActive {
                
                timerActive?.invalidate()
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
//                timerActive = NSTimer.scheduledTimerWithTimeInterval(5 * 60 * 60, target: appDelegate, selector: #selector(AppDelegate.showLoginView), userInfo: nil, repeats: false)
                 timerActive = NSTimer.scheduledTimerWithTimeInterval(10 , target: appDelegate, selector: #selector(AppDelegate.showLoginView), userInfo: nil, repeats: false)
                print("Restart auto lock timer")
            }
            
        } else {
            // Touch in progress - !ended, !cancelled, just invalidate it
//            print("Invalidate auto lock timer")
        }
        
        super.sendEvent(event)
    }
    
}
