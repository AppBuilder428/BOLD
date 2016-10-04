//
//  TestCalendarDayCell.swift
//  TestCalendar
//
//  Created by Muhammad Burhan on 11/06/2016.
//  Copyright (c) 2016 Muhammad Burhan. All rights reserved.
//

import UIKit

let cellColorDefault = UIColor(white: 0.0, alpha: 0.1)
let cellColorToday = UIColor(red: 254.0/255.0, green: 73.0/255.0, blue: 64.0/255.0, alpha: 0.3)
let borderColor = UIColor.clearColor()//(red: 254.0/255.0, green: 73.0/255.0, blue: 64.0/255.0, alpha: 0.8)

class CalendarDayCell: UICollectionViewCell {
    
    var eventsCount = 0 {
        didSet {
            for sview in self.dotsView.subviews {
                sview.removeFromSuperview()
            }
            
            let stride = self.dotsView.frame.size.width / CGFloat(eventsCount+1)
            let viewHeight = self.dotsView.frame.size.height
            let halfViewHeight = viewHeight / 2.0
            
            for _ in 0..<eventsCount {
                let frm = CGRect(x: (stride+1.0) - halfViewHeight, y: 0.0, width: viewHeight, height: viewHeight)
                let circle = UIView(frame: frm)
                circle.layer.cornerRadius = halfViewHeight
                circle.backgroundColor = borderColor
                self.dotsView.addSubview(circle)
            }
        }
    }
    
    var isToday : Bool = false {
        
        didSet {
           
            if isToday == true {
                self.pBackgroundView.backgroundColor = cellColorToday
            }
            else {
                self.pBackgroundView.backgroundColor = cellColorDefault
            }
        }
    }
    
    override var selected : Bool {
        
        didSet {
            
            if selected == true {
                self.pBackgroundView.layer.borderWidth = 2.0
                
            }
            else {
                self.pBackgroundView.layer.borderWidth = 0.0
            }
            
        }
    }
    
     lazy var pBackgroundView : UIView = {
        
        var vFrame = CGRectInset(self.frame, 3.0, 3.0)
        
        let view = UIView(frame: vFrame)
        
        view.layer.cornerRadius = 4.0
        
        view.layer.borderColor = borderColor.CGColor
        view.layer.borderWidth = 0.0
        
        view.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)
        
        view.backgroundColor = cellColorDefault
        
        
        return view
    }()
    
    lazy var textLabel : UILabel = {
       
        let lbl = UILabel()
        lbl.textAlignment = NSTextAlignment.Left
        lbl.textColor = UIColor.darkGrayColor()
        return lbl
        
    }()
    
    lazy var timeLabel : UILabel = {
        
        let lbl = UILabel()
        lbl.textAlignment = NSTextAlignment.Left
        lbl.textColor = UIColor.darkGrayColor()
        lbl.font = UIFont.systemFontOfSize(13)
        lbl.minimumScaleFactor = 0.5
        return lbl
        
    }()
    
    lazy var timeLabel1 : UILabel = {
        
        let lbl = UILabel()
        lbl.textAlignment = NSTextAlignment.Left
        lbl.textColor = UIColor.darkGrayColor()
        lbl.font = UIFont.systemFontOfSize(13)
        lbl.minimumScaleFactor = 0.5
        return lbl
        
    }()
    
    lazy var dotsView : UIView = {
        
        let frm = CGRect(x: 0, y:0, width: 0, height: 0);//(x: 8.0, y: self.frame.size.width - 10.0 - 4.0, width: self.frame.size.width - 16.0, height: 8.0)
        let dv = UIView(frame: frm)
        
        
        return dv
        
    }()

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        
        self.addSubview(self.pBackgroundView)
        var frame : CGRect?
        frame = self.bounds;
        self.textLabel.frame    = CGRectMake(5, 5, frame!.size.width-10, 20);//self.bounds
        self.timeLabel.frame    = CGRectMake(5, 25, frame!.size.width-10, 20);//self.bounds
        self.timeLabel1.frame   = CGRectMake(5, 45, frame!.size.width-10, 20);//self.bounds
        
        self.addSubview(self.textLabel)
        self.addSubview(self.timeLabel)
        self.addSubview(self.timeLabel1)
        
        self.addSubview(dotsView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
