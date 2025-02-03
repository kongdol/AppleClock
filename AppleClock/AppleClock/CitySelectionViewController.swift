//
//  CitySelectionViewController.swift
//  AppleClock
//
//  Created by yk on 1/31/25.
//

import UIKit

struct Item {
    let title: String
    let timeZone: TimeZone
}

struct Section {
    let title: String
    let itmes: [Item]
}

class CitySelectionViewController: UIViewController {

    
    @IBOutlet weak var cityTableView: UITableView!
    
    var list = [Section]()
    
    func setupList() {
        var dict = [String: [TimeZone]]()
        
        for id in TimeZone.knownTimeZoneIdentifiers {
            guard let city = id.components(separatedBy: "/").last else { continue }
            
            var timeZoneList = [TimeZone(identifier: id)!]
            let key = city.chosung ?? "Unknwon"
            
            if let list = dict[key] {
                timeZoneList.append(contentsOf: list)
            }
            
            dict[key] = timeZoneList
        }
        
        //오름차순 정렬
        for(key,value) in dict {
            let items = value.sorted {
                guard let lhs = $0.city, let rhs = $1.city else {return false}
                return lhs < rhs
            }.map {
                Item(title: $0.city ?? $0.identifier, timeZone: $0)
            }
            
            let section = Section(title: key, itmes: items)
            list.append(section)
        }
        
        list.sort {$0.title < $1.title}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupList()
        cityTableView.reloadData()
    }
}

extension CitySelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list[section].itmes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        
        let target = list[indexPath.section].itmes[indexPath.row]
        cell.textLabel?.text = target.title
        
        return cell
    }
    
    
}
