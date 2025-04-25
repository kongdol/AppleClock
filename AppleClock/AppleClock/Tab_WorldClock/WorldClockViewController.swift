//
//  WorldClockViewController.swift
//  AppleClock
//
//  Created by yk on 1/29/25.
//

import UIKit
import CoreData

class WorldClockViewController: UIViewController {

    @IBOutlet weak var worldClockTableView: UITableView!
    
    var timer: Timer?
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        worldClockTableView.setEditing(editing, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        DataManager.shared.worldClockFetchedResults.delegate = self
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
                
                let obj = DataManager.shared.worldClockFetchedResults.object(at: indexPath)
                guard let tid = obj.timeZoneId, let target = TimeZone(identifier: tid) else {
                    continue
                }
                
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataManager.shared.worldClockFetchedResults.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = DataManager.shared.worldClockFetchedResults.sections else { return 0 }
        
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WorldClockTableViewCell.self), for: indexPath) as! WorldClockTableViewCell
        
        let obj = DataManager.shared.worldClockFetchedResults.object(at: indexPath)
        if let tid = obj.timeZoneId, let target = TimeZone(identifier: tid) {
            cell.timeLabel.text = target.currentTime
            cell.timePeriodLabel.text = "  \(target.timePeriod ?? "")"
            cell.timeZoneLabel.text = target.city
            cell.timeOffsetLabel.text = target.timeOffset
        }
        
        return cell
    }
    
    // 테이블뷰 편집기능
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let obj = DataManager.shared.worldClockFetchedResults.object(at: indexPath)
            DataManager.shared.delete(object: obj)
        }
    }
    // 두번째 파라미터-시작위치, 3번째 파라미터-이동할 위치
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        DataManager.shared.worldClockFetchedResults.delegate = nil
        
        var reorderList = [WorldClockEntity]()
        
        let lowerIndex = min(sourceIndexPath.row, destinationIndexPath.row)
        let upperIndex = max(sourceIndexPath.row, destinationIndexPath.row)
        
        for i in lowerIndex ... upperIndex {
            if let object = DataManager.shared.worldClockFetchedResults.fetchedObjects?[i] {
                    reorderList.append(object)
            }
        }
        
        let removed = reorderList.remove(at: sourceIndexPath.row - lowerIndex)
        reorderList.insert(removed, at: destinationIndexPath.row - lowerIndex)
        
        for (newOrder, object) in reorderList.enumerated() {
            object.order = Int16(newOrder + lowerIndex)
        }
        
        DataManager.shared.save()
        DataManager.shared.worldClockFetchedResults.delegate = self
        
        do {
            try DataManager.shared.worldClockFetchedResults.performFetch()
        } catch {
            print(error)
        }
    }
}


extension WorldClockViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        worldClockTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
         case .insert:
            if let insertIndexPath = newIndexPath {
                worldClockTableView.insertRows(at: [insertIndexPath], with: .automatic)
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                worldClockTableView.deleteRows(at: [deleteIndexPath], with: .automatic)
            }
        case .move:
            if let originalIndexPath = indexPath, let targetIndexPath = newIndexPath {
                worldClockTableView.moveRow(at: originalIndexPath, to: targetIndexPath)
            }
        case .update:
            if let updateIndexPath = indexPath {
                worldClockTableView.reloadRows(at: [updateIndexPath], with: .automatic)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        worldClockTableView.endUpdates()
    }
}
