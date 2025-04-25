//
//  AlarmViewController.swift
//  AppleClock
//
//  Created by yk on 4/25/25.
//

import UIKit
import UserNotifications

class AlarmViewController: UIViewController {
    @IBAction func addAlarm(_ sender: Any) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("허가")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    


}
