//
//  AddAlarmTableViewController.swift
//  AppleClock
//
//  Created by yk on 4/25/25.
//

import UIKit

class AddAlarmTableViewController: UITableViewController {
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    @IBAction func toggleRepeat(_ sender: Any) {
        alarm.repeats = repeatSwitch.isOn
    }
    
    
    let alarm = AlarmEntity(context: DataManager.shared.mainContext)
    
    var weekdayString: String {
        guard let weekday = alarm.weekday, weekday.count > 0 else { return  "안 함"}
        
        var list = weekday.components(separatedBy: ",").compactMap { Int($0)}
        
        if list.count == 7 {
            return "매일"
        }
        
        // 월, 화
        let weekdayNames = list.map {
            return ["일","월","화","수","목","금","토"][$0]
        }
        
        if weekdayNames.count == 1, let first = weekdayNames.first {
            return "\(first)요일마다"
        } else {
            return weekdayNames.joined(separator: " ")
        }
    }
    
    @IBAction func selectedTimeChanged(_ sender: Any) {
        alarm.identifier = UUID().uuidString
        alarm.hour = Int16(Calendar.current.component(.hour, from: timePicker.date))
        alarm.minute = Int16(Calendar.current.component(.minute, from: timePicker.date))
    }
    
    
    
    @IBAction func closeVC(_ sender: Any) {
        DataManager.shared.rollback()
        
        dismiss(animated: true)
    }
    
    @IBAction func saveAlarm(_ sender: Any) {
        DataManager.shared.save()
        dismiss(animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WeekdaySelectionViewController {
            vc.entity = alarm
        } else if let vc = segue.destination as? LabelViewController {
            vc.entity = alarm
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        selectedTimeChanged(self)
        alarm.name = "알람"
        repeatSwitch.isOn = alarm.repeats
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        weekdayLabel.text = weekdayString
        nameLabel.text = alarm.name
    }

}
