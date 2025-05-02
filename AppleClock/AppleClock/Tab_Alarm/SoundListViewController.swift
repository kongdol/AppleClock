//
//  SoundListViewController.swift
//  AppleClock
//
//  Created by yk on 4/30/25.
//

import UIKit
import AVFoundation
import AudioToolbox

class SoundListViewController: UIViewController {

    @IBOutlet weak var soundTableView: UITableView!
    
    var entity: AlarmEntity?
    var audioPlayer: AVAudioPlayer?
    var selectedIndexPath: IndexPath?
    
    let list = ["기본 사운드", "사운드 1", "사운드 2", "사운드 3"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sound = entity?.sound, let index = list.firstIndex(of: sound) {
            selectedIndexPath = IndexPath(row: index, section: 0)
        } else {
            selectedIndexPath = IndexPath(row: 0, section: 1)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

extension SoundListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return list.count
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 1 {
            cell.textLabel?.text = "없음"
            cell.imageView?.tintColor = entity?.sound == nil ? view.tintColor : .clear
        } else {
            let target = list[indexPath.row]
            cell.textLabel?.text = target
            
            if let selected = entity?.sound, target == selected {
                cell.imageView?.tintColor = view.tintColor
            } else {
                cell.imageView?.tintColor = .clear
            }
        }
            
        return cell
    }
}

extension SoundListViewController:  UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            entity?.sound = nil
            
            audioPlayer?.stop()
            self.audioPlayer = nil
            
        } else {
            let target = list[indexPath.row]
            entity?.sound = target
            
            if indexPath.row == 0 {
                AudioServicesPlaySystemSound(SystemSoundID(1002))
            } else {
                // 다르면 다른파일 -> 새로운파일 재생
                if let audioPlayer, audioPlayer.isPlaying, let name = audioPlayer.url?.lastPathComponent,
                   name.starts(with: target) {
                    audioPlayer.stop()
                    self.audioPlayer = nil
                } else {
                    // 사운드 재생할려면 경로 필요
                    if let url = Bundle.main.url(forResource: target, withExtension: "mp3") {
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: url)
                            audioPlayer?.play()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        
        // 선택한게 다르다면 셀 해제
        if let selectedIndexPath, selectedIndexPath != indexPath {
            if let cell = tableView.cellForRow(at: selectedIndexPath) {
                cell.imageView?.tintColor = .clear
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.imageView?.tintColor = view.tintColor
        }
        
        selectedIndexPath = indexPath
    }
}
