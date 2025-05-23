//
//  AlarmViewController.swift
//  AppleClock
//
//  Created by yk on 4/25/25.
//

import UIKit
import UserNotifications
import CoreData

class AlarmViewController: UIViewController {
    
    @IBOutlet weak var alarmTableView: UITableView!
    
    
    @IBAction func toggleActivated(_ sender: UISwitch) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let target = DataManager.shared.alarmFetchedResults.object(at: indexPath)
        
        
        //예약된 노티피케이션, 이미 전달된 노티피케이션 모두 삭제, 이미 전달된거 다시 활성화 하는 방법 없음
        
        
        guard let id = target.identifier else { return }
        
        let idList: [String]
        
        if let weekday = target.weekday {
            idList = weekday.components(separatedBy: ",").compactMap{Int($0)}.map{$0 + 1}.map {
                "\(id)-\($0)"
            }
        } else {
            idList = [id]
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idList)
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idList)
        
        guard sender.isOn else {
            target.activated = sender.isOn
            DataManager.shared.save()
            return
        }
     
        let content = UNMutableNotificationContent()
        content.title = "시계"
        content.body = target.name ?? "알람"
        //content.badge = 123 // 앱아이콘에 표시됨
        content.sound = UNNotificationSound.default
        
        Task {
            do {
                // 반복요일 선택했는지
                if let weekday = target.weekday {
                    // 하나의 트리거 여러 요일 만들기 불가 - 요일마다 트리거 만들어야됨
                    let weekdayList = weekday.components(separatedBy: ",").compactMap{Int($0)}.map {$0 + 1}
                    
                    for w in weekdayList {
                        var comp = DateComponents()
                        comp.hour = Int(target.hour)
                        comp.minute = Int(target.minute)
                        comp.weekday = w
                        // 일요일 1, 월요일 2, 토요일 7
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: true)
                        //print(trigger.nextTriggerDate()?.formatted(date: .abbreviated, time: .standard))
                        
                        // 노티예약
                        let request = UNNotificationRequest(identifier: "\(target.identifier ?? "")-\(w)", content: content, trigger: trigger)
                        
                        try await UNUserNotificationCenter.current().add(request)
                    }
                }
                else {
                   // 반복 선택 안했을때
                   var comp = DateComponents()
                   comp.hour = Int(target.hour)
                   comp.minute = Int(target.minute)
                   
                   let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
                   //print(trigger.nextTriggerDate()?.formatted(date: .abbreviated, time: .standard))
                   
                   // 노티예약
                   let request = UNNotificationRequest(identifier: target.identifier ?? "", content: content, trigger: trigger)
                   
                   try await UNUserNotificationCenter.current().add(request)
               }
                target.activated = sender.isOn
                DataManager.shared.save()
                
//                for noti in await UNUserNotificationCenter.current().pendingNotificationRequests() {
//                    print(noti.identifier, (noti.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()?.formatted())
//                }
        
            } catch {
                print(error)
            }
        }
    }
    
    
    
    @IBAction func addAlarm(_ sender: Any) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                if granted {
                    DispatchQueue.main.async {
                        // 세그웨이 시작하기전에 델리게이트 잠깐 비활성
                        DataManager.shared.alarmFetchedResults.delegate = nil
                        self.performSegue(withIdentifier: "addSegue", sender: nil)
                    }
                    
                    //새로운화면표시된다음에 델리게이트 다시 활성화
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                        DataManager.shared.alarmFetchedResults.delegate = self
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showNotificationAlert()
                }
            }
        }
    }
    
    func showNotificationAlert(){
        let alert = UIAlertController(title: "알림", message: "알람을 추가하기 위해서 알림 권한이 필요합니다.\n\n설정에서 알림 권한을 허용해 주세요.", preferredStyle: .alert)
        
        let settingAction = UIAlertAction(title: "설정", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        alert.addAction(settingAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue", let cell = sender as? UITableViewCell, let indexPath = alarmTableView.indexPath(for: cell) {
            if let vc = segue.destination.children.first as? AddAlarmTableViewController {
                vc.alarm = DataManager.shared.alarmFetchedResults.object(at: indexPath)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DataManager.shared.alarmFetchedResults.delegate = self
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        alarmTableView.setEditing(editing, animated: animated)
    }
}

extension AlarmViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataManager.shared.alarmFetchedResults.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = DataManager.shared.alarmFetchedResults.sections else { return 0 }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AlarmTableViewCell.self), for: indexPath) as! AlarmTableViewCell
        
        let obj = DataManager.shared.alarmFetchedResults.object(at: indexPath)
        cell.timeLabel.text = obj.hour >= 12 ? "오후" : "오전"
        cell.timeLabel.text = "\(obj.hour > 12 ? obj.hour - 12 : obj.hour):\(obj.minute.formatted(.number.precision(.integerLength(2))))"
        cell.nameLabel.text = obj.name
        cell.activationSwitch.isOn = obj.activated
        cell.activationSwitch.tag = indexPath.row
        
        cell.timePeriodLabel.textColor = obj.activated ? .label : .secondaryLabel
        cell.timeLabel.textColor = cell.timePeriodLabel.textColor
        cell.nameLabel.textColor = cell.timePeriodLabel.textColor
        
        
        return cell
    }
    
    // 테이블뷰 편집기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let obj = DataManager.shared.alarmFetchedResults.object(at: indexPath)
            
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
            
            Task {
                for noti in await UNUserNotificationCenter.current().pendingNotificationRequests() {
                    print(noti.identifier)
                }
            }
        }
    }
}

extension AlarmViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        alarmTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
         case .insert:
            if let insertIndexPath = newIndexPath {
                alarmTableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                alarmTableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            }
        case .move:
            if let originalIndexPath = indexPath, let targetIndexPath = newIndexPath {
                alarmTableView.moveRow(at: originalIndexPath, to: targetIndexPath)
            }
        case .update:
            if let updateIndexPath = indexPath {
                alarmTableView.reloadRows(at: [updateIndexPath], with: .automatic)
            }
        default:
            break
        }
    }
    
    
    // 컨텍스트를 저장하면 디드체니지 호출되고 테이블뷰 적절하게 업데이트 될거임(델리게이트가 연결되어 있을때)
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        alarmTableView.endUpdates()
    }
}

extension AlarmViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
