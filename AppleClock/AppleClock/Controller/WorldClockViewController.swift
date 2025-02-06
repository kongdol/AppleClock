//
//  WorldClockViewController.swift
//  AppleClock
//
//  Created by yk on 1/29/25.
//

import UIKit

class WorldClockViewController: UIViewController {

    @IBOutlet weak var worldClockTableView: UITableView!
    
    var timer: Timer?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            // 분이 바뀌지 않았으면 return
            guard Date.now.minuteChanged, let self else { return }
            
            // 분이 바뀌었으면 아래코드
            for cell in self.worldClockTableView.visibleCells {
                guard let clockCell = cell as? WorldClockTableViewCell else { continue }
                guard let indexPath = self.worldClockTableView.indexPath(for: cell) else { continue }
                
                let target = list[indexPath.row]
                clockCell.timeLabel.text = target.currentTime
                clockCell.timePeriodLabel.text = " \(target.timePeriod ?? "")"
                clockCell.timeOffsetLabel.text = target.timeOffset
            }
            
            
        })
    }
    
    // 타이머중지
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
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
