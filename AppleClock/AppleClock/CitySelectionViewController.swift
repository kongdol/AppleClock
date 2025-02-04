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
    var filteredList = [Section]()
    
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
        
        // 처음에 전체 데이터 표시
        filteredList = list
    }
    
    @objc func closeVC() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색"
        searchBar.delegate = self
        
        // 이런식으로 해야 취소버튼 바로 활성화
        let btn = UIButton(type: .custom)
        btn.setTitle("취소", for: .normal)
        btn.setTitleColor(.systemOrange, for: .normal)
        btn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [searchBar, btn])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.widthAnchor.constraint(greaterThanOrEqualToConstant: view.bounds.width - 40).isActive = true
        
        navigationItem.titleView = stack
        
        
        setupList()
        cityTableView.reloadData()
    }
}

extension CitySelectionViewController: UISearchBarDelegate {
    // 바뀔떄마다 호출
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            filteredList = list
            cityTableView.reloadData()
            cityTableView.isHidden = filteredList.isEmpty
            return
        }
        // 입력되었으면
        filteredList.removeAll()
        
        for section in list {
            let items = section.itmes.filter{$0.title.lowercased().contains(searchText.lowercased())}
            
            // 일치하는 데이터가 있으면
            if !items.isEmpty {
                filteredList.append(Section(title: section.title, itmes: items))
            }
        }
        cityTableView.reloadData()
        cityTableView.isHidden = filteredList.isEmpty
    }
}

extension CitySelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList[section].itmes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        
        let target = filteredList[indexPath.section].itmes[indexPath.row]
        cell.textLabel?.text = target.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredList[section].title
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let characters: [String] = [
            // 한글 초성 (쌍자음 제외)
            "ㄱ", "ㄴ", "ㄷ", "ㄹ", "ㅁ", "ㅂ", "ㅅ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ",
            
            // 알파벳 대문자
            "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
            "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
        ]

        return characters
    }
    
    // 오른쪽 인덱스 드래그 할때마다 호출
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return filteredList.firstIndex(where: {$0.title.uppercased()==title.uppercased()}) ?? 0
    }
    
}
