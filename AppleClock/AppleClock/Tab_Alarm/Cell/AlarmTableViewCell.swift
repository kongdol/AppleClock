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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
