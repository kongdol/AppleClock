//
//  WorldClockTableViewCell.swift
//  AppleClock
//
//  Created by yk on 1/30/25.
//

import UIKit

class WorldClockTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var timeOffsetLabel: UILabel!
    @IBOutlet weak var timeZoneLabel: UILabel!
    @IBOutlet weak var timePeriodLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
