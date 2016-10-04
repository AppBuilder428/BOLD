import UIKit

class ContadoresTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var balanceTitleLabel: UILabel!
    @IBOutlet weak var requestTitleLabel: UILabel!
    @IBOutlet weak var enjoyTitleLabel: UILabel!
    @IBOutlet weak var allowedTitleLabel: UILabel!

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var requestLabel: UILabel!
    @IBOutlet weak var enjoyLabel: UILabel!
    @IBOutlet weak var allowedLabel: UILabel!


    @IBOutlet weak var balanceViewLCWidth: NSLayoutConstraint!
    @IBOutlet weak var requestViewLCWidth: NSLayoutConstraint!
    @IBOutlet weak var enjoyViewLCWidth: NSLayoutConstraint!
    @IBOutlet weak var allowedViewLCWidth: NSLayoutConstraint!

    @IBOutlet weak var balanceProgressBarViewLCWidth: NSLayoutConstraint!
    @IBOutlet weak var requestProgressBarViewLCWidth: NSLayoutConstraint!

    override func prepareForReuse() {
        
        self.balanceProgressBarViewLCWidth.constant = 0
        self.requestProgressBarViewLCWidth.constant = 0
        
    }

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.bgView.layer.cornerRadius = 4
        self.bgView.layer.shadowColor = UIColor.blackColor().CGColor
        self.bgView.layer.shadowOffset = CGSizeMake(1, 1.5)
        self.bgView.layer.borderColor = UIColor.init(hexString: "dddddd").CGColor
        self.bgView.layer.borderWidth = 1
        self.bgView.layer.shadowRadius = 5
        self.bgView.layer.shadowOpacity = 0.1

    }

    func setContadore(dict: NSDictionary!) {
        
        let name = dict.objectForKey("name") as! String

        let balance = dict.objectForKey("balance") as! CGFloat
        let request = dict.objectForKey("request") as! CGFloat
        let enjoy = dict.objectForKey("enjoy") as! CGFloat
        let allowed = dict.objectForKey("allowed") as! CGFloat
        let unit = dict.objectForKey("unit") as! Int
        
        let balanceLabel = dict.objectForKey("balanceLabel") as! String
        let requestLabel = dict.objectForKey("requestLabel") as! String
        let enjoyLabel = dict.objectForKey("enjoyLabel") as! String
        let allowedLabel = dict.objectForKey("allowedLabel") as! String
        
        var unitStr = "h" as String
        if unit == 1 {
            unitStr = "d"
        }

        self.titleLabel.text = name
        
        if (balance != -9999999) {
            
            // Case display the value
            self.balanceLabel.text = "\(formatFloatToString(balance))\(unitStr)"
            
            if balance > 0 {
                self.balanceLabel.textColor = UIColor.init(hexString: "#4CAF50")
            }
            else {
                self.balanceLabel.textColor = UIColor.redColor()
            }
            
            if balanceLabel.characters.count > 0 {
                self.balanceTitleLabel.text = balanceLabel
            }
        }
        else {
            self.balanceViewLCWidth.constant = 0
        }
        
        
        if (request != -9999999) {
            
            // Case display the value
            self.requestLabel.text = "\(formatFloatToString(request))\(unitStr)"
            
            if requestLabel.characters.count > 0 {
                self.requestTitleLabel.text = requestLabel
            }
        }
        else {
            self.requestViewLCWidth.constant = 0
        }

        
        if (enjoy != -9999999) {
            
            // Case display the value
            self.enjoyLabel.text = "\(formatFloatToString(enjoy))\(unitStr)"
            
            if enjoyLabel.characters.count > 0 {
                self.enjoyTitleLabel.text = enjoyLabel
            }
        }
        else {
            self.enjoyViewLCWidth.constant = 0
        }

        
        if (allowed != -9999999) {
            
            // Case display the value
            self.allowedLabel.text = "\(formatFloatToString(allowed))\(unitStr)"
            
            if allowedLabel.characters.count > 0 {
                self.allowedTitleLabel.text = allowedLabel
            }
        }
        else {
            self.allowedViewLCWidth.constant = 0
        }
        
        let width = CGRectGetWidth(self.contentView.frame) as  CGFloat
        var totalAmount = 0 as CGFloat
        
        var displayItem = 0 as CGFloat
        
        if (balance != -9999999) {
            totalAmount += balance
            displayItem += 1
        }

        if (request != -9999999) {
            totalAmount += request
            displayItem += 1
        }

        if (enjoy != -9999999) {
            totalAmount += enjoy
            displayItem += 1
        }

        if (allowed != -9999999) {
            displayItem += 1
        }
        
        let balanceBarWidth = balance/totalAmount * (width - 20)
        if balanceBarWidth > 0 {
            self.balanceProgressBarViewLCWidth.constant = balanceBarWidth
        }

        let requestBarWidth = request/totalAmount * (width - 20)
        if requestBarWidth > 0 {
            self.requestProgressBarViewLCWidth.constant = requestBarWidth
        }
        
        // Calculator the height of view
        let itemHeight = width/displayItem
        
        if (balance != -9999999) {
            self.balanceViewLCWidth.constant =  itemHeight
        }
        else {
            self.balanceViewLCWidth.constant =  0
        }
        
        if (request != -9999999) {
            self.requestViewLCWidth.constant =  itemHeight
        }
        else {
            self.requestViewLCWidth.constant =  0
        }
        
        if (enjoy != -9999999) {
            self.enjoyViewLCWidth.constant =  itemHeight
        }
        else {
            self.enjoyViewLCWidth.constant =  0
        }
        
        if (allowed != -9999999) {
            self.allowedViewLCWidth.constant =  itemHeight
        }
        else {
            self.allowedViewLCWidth.constant =  0
        }
        
        self.contentView .layoutIfNeeded()
    }
    
    
    func formatFloatToString(value: CGFloat) -> String
    {
        if value == CGFloat(Int(value)) {
            return String.init(format: "%d",Int(value))
        }
        else {
            return "\(value)"
        }
    }
}