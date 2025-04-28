//
//  WeekdaySelectionViewController.swift
//  AppleClock
//
//  Created by yk on 4/25/25.
//

import UIKit

class WeekdaySelectionViewController: UIViewController {
    
    @IBOutlet weak var weekdayTableView: UITableView!
    
    var entity: AlarmEntity?
    
    let weekdays = ["일요일마다","월요일마다","화요일마다","수요일마다","목요일마다","금요일마다","토요일마다"]
    var selectedRows: Set = Set<Int>() // 선택한 인덱스 저장을 위한 set
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let weekday = entity?.weekday { // 1,2,3
            let rows = weekday.components(separatedBy: ",").compactMap { Int($0) } // 콤마로 분리 정수로 바꿈
            selectedRows = Set(rows)
            weekdayTableView.reloadData()
        }
    }
       
}


extension WeekdaySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = weekdays[indexPath.row]
        
        //셀을 재사용할때도 체크마크를 적절히 사용, 이코드 없으면 선택하지않은 셀에서 체크마크가 표시된 셀을 재사용할수도 있음
        cell.accessoryType = selectedRows.contains(indexPath.row) ? .checkmark : .none
        
        return cell
    }
    
    
}

extension WeekdaySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedRows.contains(indexPath.row) {
            selectedRows.remove(indexPath.row)
            
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
        } else {
            selectedRows.insert(indexPath.row)
            
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }
        }
        
        if let entity {
            if selectedRows.isEmpty {
                entity.weekday = nil
            } else {
                entity.weekday = selectedRows.map { "\($0)"}.sorted().joined(separator: ",") //문자열, 오름차순정렬, 콤마로 연결해서 -> 하나의 문자열로 저장
            }
        }
    }
}
