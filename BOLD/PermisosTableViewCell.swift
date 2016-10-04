import UIKit

class PermisosTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startTimeTitleLabel: UILabel!
    @IBOutlet weak var endTimeTitleLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var changeTimeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var topLCTitle: NSLayoutConstraint!

    var inputDateFormatter: NSDateFormatter?
    var inputChangeDateFormatter: NSDateFormatter?
    var outputDateFormatter: NSDateFormatter?
    var outputHourFormatter: NSDateFormatter?

    var permisosData: NSDictionary?
    
    func setPermisos(data: NSDictionary!) {
        
        self.permisosData = data
        
        self.endTimeTitleLabel.hidden = false
        self.endTimeLabel.hidden = false
        
        self.startTimeTitleLabel.text = "Desde: "
        self.endTimeTitleLabel.text = "Hasta: "

        let abbreviation = data.objectForKey("abbreviation") as! String
        let colour = data.objectForKey("colour") as! String
        
        let name = data.objectForKey("name") as! String
        let stringStartDate = data.objectForKey("startDate") as! String
        let stringEndDate = data.objectForKey("endDate") as! String
        let changeDate = data.objectForKey("changeDate") as! String
        let status = data.objectForKey("status") as! Int
        let isFullDay = data.objectForKey("isFullDay") as! Int
        
        self.iconLabel.text = abbreviation
        self.iconLabel.backgroundColor = UIColor.init(hexString: colour)
        self.nameLabel.text = name
        self.topLCTitle.constant = 8

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
                
                self.topLCTitle.constant = 18
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
            break;
        case 1:
            self.statusLabel.text = " Denegado  "
            self.statusLabel.backgroundColor = UIColor.init(204, green: 45, blue: 41)
            break;
            
        default:
            self.statusLabel.text = " Aprobado  "
            self.statusLabel.backgroundColor = UIColor.init(55, green: 152, blue: 36)
        }
        
        self.contentView.layoutIfNeeded()

        let permisosId = data.objectForKey("ID") as! NSNumber
        
        if changedPermisosIds .contains(permisosId) {
            
            self.bgView.alpha = 1.0
            self.bgView.hidden = false
            self.bgView.backgroundColor = UIColor.init(255, green: 255, blue: 0, alpha: 0.5)

            self .performSelector(#selector(hightLightOff), withObject: nil, afterDelay: 10)
        }
        else {
            self.bgView.hidden = true
        }
    }
    
    func hightLightOff() {
        
        self.contentView.backgroundColor = UIColor.whiteColor()
        
        let permisosId = self.permisosData!.objectForKey("ID") as! NSNumber
        
        if changedPermisosIds .contains(permisosId) {
            
            let position = changedPermisosIds.indexOf(permisosId)
            changedPermisosIds.removeAtIndex(position!)
            
            UIView .animateWithDuration(1, animations: {
                self.bgView.alpha = 0.0
            })
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
}

