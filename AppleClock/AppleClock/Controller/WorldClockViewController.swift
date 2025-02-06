//
//  WorldClockViewController.swift
//  AppleClock
//
//  Created by yk on 1/29/25.
//

import UIKit

class WorldClockViewController: UIViewController {

    @IBOutlet weak var worldClockTableView: UITableView!
    
    var list = [
        TimeZone(identifier: "Asia/Seoul")!,
        TimeZone(identifier: "Europe/Paris")!,
        TimeZone(identifier: "America/New_York")!,
        TimeZone(identifier: "Asia/Tehran")!,
        TimeZone(identifier: "Asia/Vladivostok")!
    ]
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        worldClockTableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem

        NotificationCenter.default.addObserver(forName: .timeZoneDidSelect,object: nil, queue: .main){ [weak self] noti in
            guard let self, let timeZone = noti.userInfo?["timeZone"] as? TimeZone else {
                return
            }
            
            guard !self.list.contains(where: {$0.identifier == timeZone.identifier}) else {
                return
            }
            
            self.list.append(timeZone)
            self.worldClockTableView.reloadData()
        }
    }
    

}

extension WorldClockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WorldClockTableViewCell.self), for: indexPath) as! WorldClockTableViewCell
        
        let target = list[indexPath.row]
        cell.timeLabel.text = target.currentTime
        cell.timePeriodLabel.text = "  \(target.timePeriod ?? "")"
        cell.timeZoneLabel.text = target.city
        cell.timeOffsetLabel.text = target.timeOffset
        
        return cell
    }
    
    // 테이블뷰 편집기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    // 두번째 파라미터-시작위치, 3번째 파라미터-이동할 위치
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let target = list.remove(at: sourceIndexPath.row)
        
        list.insert(target, at: destinationIndexPath.row)
    }
    
}
