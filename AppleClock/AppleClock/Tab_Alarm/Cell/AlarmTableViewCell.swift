//
//  AlarmTableViewCell.swift
//  AppleClock
//
//  Created by yk on 4/29/25.
//

import UIKit

class AlarmTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var activationSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        UIView.animate(withDuration: 0.3) {
            self.activationSwitch.alpha  = editing ? 0 : 1
        }
    }

}
