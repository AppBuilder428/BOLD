//
//  MJWeekLabelsView.swift
//  Pods
//
//  Created by Michał Jackowski on 23.11.2015.
//
//

import UIKit

class MJWeekLabelsView: MJComponentView {
    var weekLabels: [UILabel] = []
    var dayWeekText: [String] {
        if self.delegate.configurationWithComponent(self).startDayType == .Monday {
            return [
                "Lu",
                "Ma",
                "Mi",
                "Ju",
                "Vi",
                "Sa",
                "Do"
            ]
//            return [
//                "MON",
//                "TUE",
//                "WED",
//                "THU",
//                "FRI",
//                "SAT",
//                "SUN"
//            ]
        } else {
            return [
                "Do",
                "Lu",
                "Ma",
                "Mi",
                "Ju",
                "Vi",
                "Sa"
            ]
        }
    }
    
    override init(delegate: MJComponentDelegate) {
        super.init(delegate: delegate)
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpView() {
        for i: Int in 0...6 {
            let label = UILabel()
            label.font = self.delegate.configurationWithComponent(self).weekLabelFont
            label.textColor = self.delegate.configurationWithComponent(self).weekLabelTextColor
            label.text = self.dayWeekText[i]
            label.textAlignment = .Center
            label.backgroundColor = UIColor.whiteColor()
            self.addSubview(label)
            self.weekLabels.append(label)
        }
    }
    
    func updateView() {
        for (index, weekLabel) in self.weekLabels.enumerate() {
            weekLabel.font = self.delegate.configurationWithComponent(self).weekLabelFont
            weekLabel.textColor = self.delegate.configurationWithComponent(self).weekLabelTextColor
            weekLabel.text = self.dayWeekText[index]
        }
    }
    
    override func updateFrame() {
        for (index, weekLabel) in self.weekLabels.enumerate() {
            let labelWidth: CGFloat = self.width() / 7
            weekLabel.frame = CGRectMake(CGFloat(index) * labelWidth, 0, labelWidth, self.height())
        }
    }
}
