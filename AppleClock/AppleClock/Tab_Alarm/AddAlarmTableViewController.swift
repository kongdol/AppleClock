//
//  AddAlarmTableViewController.swift
//  AppleClock
//
//  Created by yk on 4/25/25.
//

import UIKit
import UserNotifications

class AddAlarmTableViewController: UITableViewController {
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    
    
    @IBOutlet weak var soundLabel: UILabel!
    
    
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    @IBAction func toggleRepeat(_ sender: Any) {
        alarm?.repeats = repeatSwitch.isOn
    }
    
    
    var alarm: AlarmEntity?
    var originalWeekday: String?
    
    var weekdayString: String {
        guard let weekday = alarm?.weekday, weekday.count > 0 else { return  "안 함"}
        
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
        alarm?.hour = Int16(Calendar.current.component(.hour, from: timePicker.date))
        alarm?.minute = Int16(Calendar.current.component(.minute, from: timePicker.date))
    }
    
    
    
    @IBAction func closeVC(_ sender: Any) {
        DataManager.shared.rollback()
        
        dismiss(animated: true)
    }
    
    @IBAction func saveAlarm(_ sender: Any) {
        //편집인지확인
        if let alarm, !alarm.isInserted {
            if let id = alarm.identifier {
                let idList: [String]
                
                // 편집할때 바뀔수도 있으니까 entity에 현재값에 접근하면 안되고 weekday에 따로 저장하고 여기에 접근해야됨
                if let weekday = originalWeekday { // 기존노티삭제됨
                    idList = weekday.components(separatedBy: ",").compactMap{Int($0)}.map{$0 + 1}.map {
                        "\(id)-\($0)"
                    }
                } else {
                    idList = [id]
                }
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idList)
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idList)
            }
            
        }
        
        
        selectedTimeChanged(self)
        
        
        
        let content = UNMutableNotificationContent()
        content.title = "시계"
        content.body = alarm?.name ?? "알람"
        //content.badge = 123 // 앱아이콘에 표시됨
        // content.sound = UNNotificationSound(named: UNNotificationSoundName("사운드 1.mp3"))
        if let alarm, alarm.repeats {
            content.categoryIdentifier = CategoryIdentifier.alarm.rawValue
        }
        
        
        if let sound = alarm?.sound {
            if sound == "기본 사운드" {
                content.sound = UNNotificationSound.default
            } else {
                content.sound = UNNotificationSound(named: UNNotificationSoundName("\(sound).mp3"))
            }
        }
        
        Task {
            do {
                // 반복요일 선택했는지
                if let weekday = alarm?.weekday {
                    // 하나의 트리거 여러 요일 만들기 불가 - 요일마다 트리거 만들어야됨
                    let weekdayList = weekday.components(separatedBy: ",").compactMap{Int($0)}.map {$0 + 1}
                    
                    for w in weekdayList {
                        var comp = DateComponents()
                        comp.hour = Int(alarm?.hour ?? 0)
                        comp.minute = Int(alarm?.minute ?? 0)
                        comp.weekday = w
                        // 일요일 1, 월요일 2, 토요일 7
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
                        //print(trigger.nextTriggerDate()?.formatted(date: .abbreviated, time: .standard))
                        
                        // 노티예약
                        let request = UNNotificationRequest(identifier: "\(alarm?.identifier ?? "")-\(w)", content: content, trigger: trigger)
                        
                        try await UNUserNotificationCenter.current().add(request)
                    }
                }
                else {
                   // 반복 선택 안했을때
                   var comp = DateComponents()
                   comp.hour = Int(alarm?.hour ?? 0)
                   comp.minute = Int(alarm?.minute ?? 0)
                   
                   let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
                   //print(trigger.nextTriggerDate()?.formatted(date: .abbreviated, time: .standard))
                   
                   // 노티예약
                   let request = UNNotificationRequest(identifier: alarm?.identifier ?? "", content: content, trigger: trigger)
                   
                   try await UNUserNotificationCenter.current().add(request)
               }
                
                
                alarm?.activated = true
                DataManager.shared.save()
                dismiss(animated: true)
                
                for noti in await UNUserNotificationCenter.current().pendingNotificationRequests() {
                    print(noti.identifier)
                }
            } catch {
                print(error)
            }
        }
        
         
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WeekdaySelectionViewController {
            vc.entity = alarm
        } else if let vc = segue.destination as? LabelViewController {
            vc.entity = alarm
        } else if let vc = segue.destination as? SoundListViewController {
            vc.entity = alarm
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if let alarm {
            var comp = DateComponents()
            comp.hour = Int(alarm.hour ?? 0)
            comp.minute = Int(alarm.minute ?? 0)
            
            if let date = Calendar.current.date(from: comp) {
                timePicker.date = date
            }
           
            originalWeekday = alarm.weekday
           
            navigationItem.title = "알람 편집"
        } else { //추가
            alarm = AlarmEntity(context: DataManager.shared.mainContext)
            alarm?.identifier = UUID().uuidString
            selectedTimeChanged(self)
            alarm?.name = "알람"
            alarm?.sound = "기본 사운드"
            
            navigationItem.title = "알람 추가"
        }
        repeatSwitch.isOn = alarm?.repeats ?? true
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        weekdayLabel.text = weekdayString
        nameLabel.text = alarm?.name
        soundLabel.text = alarm?.sound ?? "없음"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let alarm else {return 0}
        
        // isInserted(삽입대기중) - true, contextSave안됨
        // false면 영구저장이고 편집이니까 2(삭제버튼표시)
        return !alarm.isInserted ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            guard let obj = alarm else {return}
            
            if let id = obj.identifier {
                let idList: [String]
                
                if let weekday = obj.weekday {
                    idList = weekday.components(separatedBy: ",").compactMap{Int($0)}.map{$0 + 1}.map {
                        "\(id)-\($0)"
                    }
                } else {
                    idList = [id]
                }
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idList)
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idList)
            }
            
            DataManager.shared.delete(object: obj)
            dismiss(animated: true)
        }
    }

}
