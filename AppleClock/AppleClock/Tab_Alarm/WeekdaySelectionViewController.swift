//
//  WeekdaySelectionViewController.swift
//  AppleClock
//
//  Created by yk on 4/25/25.
//

import UIKit

class WeekdaySelectionViewController: UIViewController {
    
    @IBOutlet weak var weekdayTableView: UITableView!
    
    let weekdays = ["일요일마다","월요일마다","화요일마다","수요일마다","목요일마다","금요일마다","토요일마다"]
    var selectedRows: Set = Set<Int>() // 선택한 인덱스 저장을 위한 set
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
    }
}
